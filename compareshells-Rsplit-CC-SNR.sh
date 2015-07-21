#!/bin/bash

# original: fom=( R1I R1F R2 Rsplit CC CC CCstar )

echo ""
echo "Use: "
echo "compareshells.sh  shelldir1  shelldir2  "
#echo "output format = png or eps or whatever else gnuplot can handle "
echo "it will plot shelldir1/shells-CC.dat vs shelldir2/shells-CC.dat "
echo ""
echo "Don't forget to set xrange and x2range to equal your shell resolution range, or domain of interest"
echo ""


dir1="${1//.stream}"
dir2="${2//.stream}"
file1="${dir1//shells_}"
file2="${dir2//shells_}"

fom=( CCstar )

for ELEMENT in $(seq 0 $((${#fom[@]} - 1))) 
do


gnuplot <<- EOF
	set terminal png
	set font 'Times, 18'
	set output "${fom[$ELEMENT]}-$1-vs-$2.png"
#	set ytics font "Helvetica, 16"
	set xlabel "1/d (nm)" 
#	set xlabel font "Helvetica, 16"
#	set xtics font "Helvetica, 16"
	set x2label "Angstroms" 
#	set x2label font "Helvetica, 16" 
	set x2range [0.1:4.0]
	set xrange [0.1:4.0]
#	set x2tics font "Helvetica, 16"
	set x2tics ("5.0" 2.0, "3.33" 3.0, "4.0" 2.5, "6.67" 1.5, "3.00" 3.3333, "2.65" 3.772, "2.37" 4.225)
#	set ylabel font "Helvetica, 20"
	set ylabel "${fom[$ELEMENT]}"
	plot "$1/${fom[$ELEMENT]}.dat" u 1:2 w lp lt 1 lw 3, "$2/${fom[$ELEMENT]}.dat" u 1:2 w lp lt 3 lw 3
	EOF
	
done

fom=( Rsplit )

for ELEMENT in $(seq 0 $((${#fom[@]} - 1))) 
do


gnuplot <<- EOF
	set terminal png
	set font 'Times, 18'
	set output "${fom[$ELEMENT]}-$1-vs-$2.png"
#	set ytics font "Helvetica, 16"
	set xlabel "1/d (nm)" 
#	set xlabel font "Helvetica, 16"
#	set xtics font "Helvetica, 16"
	set x2label "Angstroms" 
#	set x2label font "Helvetica, 16" 
	set x2range [0.1:4.0]
	set xrange [0.1:4.0]
#	set x2tics font "Helvetica, 16"
	set x2tics ("5.0" 2.0, "3.33" 3.0, "4.0" 2.5, "6.67" 1.5, "3.00" 3.3333, "2.65" 3.772, "2.37" 4.225)
#	set ylabel font "Helvetica, 20"
	set ylabel "${fom[$ELEMENT]}"
	set yrange [0:200]
	plot "$1/${fom[$ELEMENT]}.dat" u 1:2 w lp lt 1 lw 3, "$2/${fom[$ELEMENT]}.dat" u 1:2 w lp lt 3 lw 3
	EOF
	
done

#	plot "CC.dat" u 1:2 w lp, "CC-ignorenegs.dat" u 1:2 w lp, "CC-zeronegs.dat" u 1:2 w lp, "CC-sigmamin-1.0.dat" u 1:2 w lp

gnuplot <<- EOF
	set terminal png
	set font 'Times, 18'
	set output "SNR-$1-vs-$2.png"
#	set ytics font "Helvetica, 16"
	set xlabel "1/d (nm)" 
#	set xlabel font "Helvetica, 16"
#	set xtics font "Helvetica, 16"
	set x2label "Angstroms" 
#	set x2label font "Helvetica, 16" 
	set x2range [0.1:4.0]
	set xrange [0.1:4.0]
#	set x2tics font "Helvetica, 16"
	set x2tics ("5.0" 2.0, "3.33" 3.0, "4.0" 2.5, "6.67" 1.5, "3.00" 3.3333, "2.65" 3.772, "2.37" 4.225)
#	set ylabel font "Helvetica, 20"
	set ylabel "I / sig(I)"
	plot "$1/mergingstats-$file1.dat" u 1:7 w lp lt 1 lw 3, "$2/mergingstats-$file2.dat" u 1:7 w lp lt 3 lw 3
	EOF
	
echo ""
echo "display SNR-$1-vs-$2.png"
echo "display CCstar-$1-vs-$2.png"
echo "display Rsplit-$1-vs-$2.png"

