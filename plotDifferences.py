
try:
	import sys
	import os
	import time
	import numpy as np
	import matplotlib.pyplot as plt
	import matplotlib.ticker as ticker
	import seaborn as sns

except:
	print("Could not import required modules. Please ensure availability of:")
	print("numpy, scipy, and matplotlib")

infile="03_gnss/1608_GNSS_diff_to_DTM_vals.txt"
data=[]

with open(infile,"r") as ifo:
	for line in ifo:
		val=float(line.strip())
		data.append(val)
		
data=np.array(data)
print(data)
		
print("Number of input values: %i" % len(data))

print("Generating plot...")

ax = sns.distplot(data,color="k",bins=[-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7])

ax.xaxis.set_major_locator(ticker.MultipleLocator(0.1))

plt.xlabel("Vertical difference [m]")
plt.ylabel("Frequency [DN]")

#plt.show()
plt.savefig("05_plots\plot_dist_GNSS2DTM.png",dpi=600)
plt.close()

print("STATISTICS")
print("Mean:	%.3f" % (np.mean(data)))
print("Min:	%.3f" % (np.min(data)))
print("Max:	%.3f" % (np.max(data)))
print("Median:	%.3f" % (np.median(data)))
print("Stdev.:	%.3f" % (np.std(data)))