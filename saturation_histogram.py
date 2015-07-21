#!/reg/g/psdm/sw/releases/ana-current/arch/x86_64-rhel5-gcc41-opt/bin/python

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm

data = np.loadtxt("peaks.txt", skiprows=1,usecols=(8,13),delimiter=",")
x = data[:,0]
y = data[:,1]
H,xedges,yedges = np.histogram2d(y,x,bins=300)
fig = plt.figure()
ax1 = plt.subplot(111)
plot = ax1.pcolormesh(yedges,xedges,H, norm=LogNorm())
cbar = plt.colorbar(plot)
plt.xlabel("r (npixels, assembled)")
plt.ylabel("Intensity")
plt.savefig("saturation_histogram", ext="png")
