#!/bin/bash

if [ -z "$1" ] ; then 
  echo "No input given"
  echo Use:  ./analysehkls-full.sh indexamajigoutput.stream unit-cell.pdb process_N_crystals_only
  exit 1
fi

thisone=$1
pdb=$2
sym="6/m"
apparent_sym="6/mmm"
lowres=100   # Å
highres=3.5   # Å
nshells=15
toggle_scale="--scale"
#toggle_scale=""
[ ! -z "$3" ] && toggle_use_n_xtals="--stop-after=$3"
[ ! -z "$3" ] && toggle_use_halfn_xtals="--stop-after=$(($3/2))"

if [ ! -f ambigated_$1 ] ; then
ambigator $1 -y $sym -w $apparent_sym -o ambigated_$1 \
				--lowres=10 --highres=3  \
				-j 32 --iterations=20 --ncorr=1000
#-operator=k,h,-l 
fi
thisone=ambigated_$1
statdir="${thisone//.stream}"

if [ ! -f $thisone.hkl ]; then
	echo "Processing $thisone into $statdir.hkl"
	process_hkl     -i $thisone -o $thisone.hkl -y $sym $toggle_scale $toggle_use_n_xtals
fi

if [ ! -f $thisone.even ] || [ ! -f $thisone.odd ]; then 
	echo "Cutting $thisone into alternate odd and even streams"
	alternate-stream $thisone $thisone.even $thisone.odd
fi

if [ ! -f $thisone.even.hkl ] || [ ! -f $thisone.odd.hkl ]; then
	echo "Processing even and odd streams"
	process_hkl     -i $thisone.even -o $thisone.even.hkl -y $sym $toggle_scale $toggle_use_halfn_xtals
	process_hkl     -i $thisone.odd -o $thisone.odd.hkl -y $sym $toggle_scale $toggle_use_halfn_xtals
fi

echo "" ; echo Calculating Wilson statistics with low res = $lowres A, high res = $highres A ; echo ""
check_hkl $thisone.hkl -y $sym -p $pdb --lowres=$lowres --highres=$highres  --wilson \
          --shell-file="wilsonstats-${thisone//.stream}.dat" --nshells=$nshells  2>&1 | tee check_hkl_wilson.log

echo "" ; echo Checking hkl file quality with low res = $lowres A, high res = $highres A ; echo ""
check_hkl $thisone.hkl -y $sym -p $pdb --lowres=$lowres --highres=$highres  \
          --shell-file="mergingstats-${thisone//.stream}.dat" --nshells=$nshells  2>&1 | tee check_hkl.log

#check_hkl $thisone.hkl -y $sym -p $pdb --rmax=$rmax --rmin=$rmin \
#          --sigma-cutoff=1 --shell-file=$thisone.hkl-sigmamin-1.0 --nshells=$nshells 
#2>&1 | $


echo "" ; echo Comparing even.hkl and odd.hkl with low res = $lowres A, high res = $highres A ; echo ""
# Save results in separate directory
shellsdir=shells_$statdir_$lowres-to-$highres
if [ ! -d $shellsdir ]; then mkdir $shellsdir ; fi
mv "wilsonstats-${thisone//.stream}.dat" check_hkl*log \
   "mergingstats-${thisone//.stream}.dat" $shellsdir


for ELEMENT in Rsplit CCstar CC ; do
echo "===================== " ; echo $ELEMENT ; echo "===================== "

compare_hkl $thisone.even.hkl $thisone.odd.hkl \
                --fom=$ELEMENT \
                -p $pdb \
                --shell-file="$ELEMENT.dat" \
                -y $sym \
                --lowres=$lowres \
                --highres=$highres \
                --nshells=$nshells \
                2>&1 | tee compare_hkl-$ELEMENT.log
echo " "

mv $ELEMENT.dat $shellsdir
mv compare_hkl*log $shellsdir

done

xmax=$(awk "BEGIN {printf \"%.2f\", 10.0/${highres}}")
xmin=$(awk "BEGIN {printf \"%.2f\", 10.0/${lowres}}")

echo x range is  $xmin  to $xmax in 1/nm


# Plot CC and R split
gnuplot <<EOF
#set term postscript enhanced color
set term png
set output "stats-$statdir-$lowres-to-$highres-Å.png"
set ylabel "R split (%)"
# font "sans, 24"
set yrange [0:120]
#set ytics font "sans, 20"
#set y2tics font "sans, 20"
set y2tics  ("0.2" 20, "0.4" 40, "0.6" 60, "0.8" 80, "1.0" 100)
set y2label "CC star     "
#font "sans, 24"
#set xtics font "sans, 20"
set x2label "resolution (Angstroms)"
#font "sans, 16"
set xrange [$xmin:$xmax]
set xlabel "1/d (nm^-1)"
#set x2tics font "sans, 16"
set x2tics ("5.0" 2.0, "3.33" 3.0, "4.0" 2.5, "6.67" 1.5, "3.00" 3.3333, "2.65" 3.772, "2.37" 4.225, "10" 1.0, "100" 0.1, "50" 0.2)
#set ylabel font "sans, 20"
set key spacing 1.5 top right
#font "sans, 24"
plot "$shellsdir/CCstar.dat" u 1:(\$2)*100 w lp lt 3 lw 3 title "CC* - $statdir", \
"$shellsdir/CC.dat" u 1:(\$2)*100 w lp title "CC 1/2 - $statdir" lt 4 lw 3, \
"$shellsdir/Rsplit.dat" u 1:2 w lp title "R_split % - $statdir" lt 2 lw 3, 50 lt 0
EOF


echo 
echo display "stats-$statdir-$lowres-to-$highres-Å.png"
echo


workdir=$(pwd)
cd ~/software/crystfel
git rev-parse HEAD >> commitid
mv commitid $workdir
cd $workdir
echo "CrystFEL commit used: " > analysis-parameters.txt
cat commitid >> analysis-parameters.txt

cat <<EOM >> analysis-parameters.txt

streams = $statdir
pdb = $pdb
sym = $sym
low res = $lowres
high res = $highres
nshells = $nshells
process_hkl with $toggle_use_n_xtals , i.e. included $3 crystals

EOM

head -n 25 $thisone >> analysis-parameters.txt
#ave-resolution $thisone >> analysis-parameters.txt 
mv analysis-parameters.txt $shellsdir
rm commitid

open "stats-$statdir-$lowres-to-$highres-Å.png"


