#!/bin/python
# -*- coding: utf-8 -*-


__author__ = "Katharina Anders"
__date__ = "2017-06-06"
__copyright__ = "(c) 3D Geospatial Data Processing Group (3DGeo), Heidelberg University (2017-)"
__version__ = "1.0"


def info():
	print('''TERRAIN PROBABILITY SCRIPT
	
  This script uses amplitude and echo width of returns to assign 
  a terrain probability to each point of a point cloud based on 
  the approach presented in Muecke et al. (2010).

  Reference: Muecke, W., Briese, C. & Hollaus, M. (2010). Terrain 
  Echo Probability Assignment based on Full-Waveform Airborne Laser 
  Scanning Observables. ISPRS TC VII Symposium - 100 Years ISPRS, 
  Vienna, Austria. 157-162.
	
  Script (c) 3DGeo, Heidelberg University (2017-)
  
  Modified by Inge Gruenberg, AWI, 02/2021 to fit only 2 of the 3 parameters
  Modified by Stephan Lange, AWI, 03/2021 with manual fit
''')

try:
	import sys
	import os
	import time
	import numpy as np
	import matplotlib.pyplot as plt
	from scipy.optimize import curve_fit
except:
	print("Could not import required modules. Please ensure availability of:")
	print("numpy, scipy, and matplotlib")

def countLines(file):
	with open(file,"r") as ifo:
		c=0
		for line in ifo:
			c+=1
	return c

	
def readInput(infile,colAmpl,colEW,linecount):
	print("\nReading input data...")
	data = np.empty([linecount, 2])  # array with [echowidth, amplitude]
	with open(infile, "r") as ifo:
		c = 0
		for line in ifo:
			cols = line.strip().split(" ")
			amplitude = float(cols[colAmpl])
			echowidth = float(cols[colEW])
			data[c, 0] = echowidth
			data[c, 1] = amplitude
			c += 1
			if c % 10000 == 0:
				print("\r%i lines of %i read" % (c, linecount),)
	print("\r%i of %i lines read" % (c, linecount))
	return data


# def func(x, a, b, c):
# 	return a * np.exp(-b * x) + c
def funcLeft(x, a):
	return a * np.exp(2 * x) + 6
def funcRight(x, a):
	return a * np.exp(-2 * x) + 6
#def funcLeft(x, a, b):
#	return a * np.exp(2.45 * x) + b
#def funcRight(x, a, b):
#	return a * np.exp(-2.45 * x) + b


def createsub(data,num):
    print("Extracting a subset of size %i from the input point cloud data..." % num)
    np.random.seed(185)
    np.random.shuffle(data)
    data_sub = data[:num]
    return data_sub


def clip_data(data_sub,medEW):
	mask = data_sub[:, 0] <= medEW
	size = np.sum(mask)
	data_lefteq = np.empty([size, 2])  # array with [echowidth, amplitude]
	n=0
	for d in data_sub:
		ew = d[0]
		if ew <= medEW:
			data_lefteq[n] = d
			n = n + 1
	return data_lefteq

def usage():
	print("--- USAGE ---")
	print("%s <input point cloud file> <column id with amplitude values> <column id with echo width values> <number of points to use as point cloud subset (default: 150 mio.)" % sys.argv[0])
	print("(e.g.: %s ALS_data.txt 4 5 15000000)" % sys.argv[0])
	
def main(): 
    try:
        infile = sys.argv[1]			# e.g. "ALS_data.txt"
        colAmpl = int(sys.argv[2])-1	# column in infile with amplitude values
        colEW = int(sys.argv[3])-1	# column in infile with echo width values
        try:
            numPtsUsed = int(sys.argv[4])	# number of points to use as a (random) subset of the input point cloud data
        except:
         	numPtsUsed = 150000000
        basename = os.path.basename(infile).strip().split(".")[0]
    except:
        print("Error in script call\n")
        usage()
        print("\nExit")
        sys.exit()

# infile="02_intermediate/ALS1_all_echotypes_SOR.txt"			# e.g. "ALS_data.txt"
# colAmpl=4-1	# column in infile with amplitude values
# colEW=5-1	# column in infile with echo width values
# numPtsUsed=10000000
# basename=os.path.basename(infile).strip().split(".")[0]	
	
    info()
	
    starttime = time.time()

# read in data from input file
    linecount = countLines(infile)
    data = readInput(infile,colAmpl,colEW,linecount)

# if applicable, create a subset of the point cloud data
    if linecount > numPtsUsed:
        data = createsub(data,numPtsUsed)
        linecount = numPtsUsed

# statistics
    print("\nDetermining median values of echo width and amplitude...")
    medEW, medAMP = np.ma.median(data, axis=0)

    data_lefteq = clip_data(data, medEW)

# extract upper points for curve fit to flank (threshold: 90% ampl. for 0.1 bins of echo width)
    print("Fitting curve to point distribution...")
    data_inline = []
    n = data_lefteq.size
    bin_start = n
    therange = np.arange(np.min(data_lefteq[:,0]),(np.max(data_lefteq[:,0])+0.1),0.1)
    for bin_start in therange:
        data_bin = []
        bin_end = bin_start+0.1
        for el in data_lefteq:
            ew=el[0]
            if ew >= bin_start and ew < bin_end:
                #crashed
                data_bin.append(el)
        if len(data_bin)<1:
            continue
        data_bin=np.array(data_bin)
        npts=10
        db = np.argsort(data_bin[:,1])[-npts:]
        for idb in db:
            data_inline.append(data_bin[idb])

# fit curve to data on left flank
    data_inline=np.array(data_inline)
    xdata = data_inline[:,0]
    ydata = data_inline[:,1]
    try:
        popt, pcov = curve_fit(funcLeft, xdata, ydata,  p0=(0))
    except:
        print("ERROR: Could not fit a curve to the input data. Try increasing the subset size to a representative number or check the input file.")
        print(xdata)
        print(ydata)
        print(medEW)
        sys.exit(-1)

# fit curve to data flipped to right flank
    data_inline_right=data_inline.copy()
    data_inline_right[:,0]=data_inline_right[:,0] + 2*(medEW-data_inline_right[:,0])
    xdata_r = data_inline_right[:,0]
    ydata_r = data_inline_right[:,1]
    popt_mirr, pcov_mirr = curve_fit(funcRight, xdata_r, ydata_r)

# shift curve as transition zone
    xdata_r_shifted = xdata_r.copy()+0.5
    try:
        popt_mirr_shft, pcov_mirr_shft = curve_fit(funcRight, xdata_r_shifted, ydata_r)
    except:
        print("ERROR: Could not fit a mirrored curve to the input data. Try increasing the subset size to a representative number.")
        sys.exit(-1)

    print("Generating scatter plot...")
    fig = plt.figure()
    ax = fig.add_subplot(111)
# scatter all data (ew, amp) in plot; add median line
    ax.scatter(data[:,0], data[:,1], color="gray", s=15.0,  alpha = 0.4, label='Data')
    ax.text(0.42, 0.6, 'y = %5.3f * exp(+/-2 * x) + 6' % tuple(popt), transform = ax.transAxes)
    plt.axvline(x = medEW, c = 'black', alpha = 0.9, label = 'Mean', linewidth = 0.9)

    plt.ylim(0,600)
    plt.xlim(0,50)

# add grid
    ax.set_axisbelow(True)
    plt.grid(True, color = 'gray', linestyle = 'dashed', linewidth = 0.5)

# plot left-side curve
    plt.plot(xdata, funcLeft(xdata, *popt), 'r-', label = 'Curve fit to left flank', linewidth = 0.9)

# plot right side curve (mirrored around median)
    plt.plot(xdata_r, funcRight(xdata_r, *popt_mirr), 'r--', label = 'Curve flipped along mean', linewidth = 0.9)

# plot shifted curve (transition zone)
    plt.plot(xdata_r_shifted, funcRight(xdata_r_shifted, *popt_mirr_shft), color = 'orange', linestyle = 'dashed', label = 'Curve delineating transition zone', linewidth = 0.9)

    plt.fill_between(xdata, 0, funcLeft(xdata, *popt),color = "red",alpha = 0.25, edgecolor = 'none')
    plt.fill_between(xdata_r, 0, funcRight(xdata_r, *popt_mirr),color = "red",alpha = 0.25, edgecolor = 'none')

    plt.xlabel("Echo Width [ns]")
    plt.ylabel("Amplitude [DN]")
    plt.legend()

#plt.show()
    figname = "05_plots/scatter_terrain_probability.png"
    plt.savefig(figname,dpi = 300)
    print("Plot written to:", figname)

# construct curve values
# y_left = func(xdata, *popt)
# y_right = func(xdata_r, *popt_mirr)
# y_shifted = func(xdata_r_shifted, *popt_mirr_shft)


# store terrain probability info as attribute to new file
    print("\nAdding terrain probability to point cloud file: 0%% done",)
    c = 0
    p = 5
    outfile= "02_intermediate/" + basename + "_terrainprob_last.txt"
    with open(outfile,"w") as f:
        with open(infile,"r") as ifo:
            c = 0
            for line in ifo:
                cols = line.strip().split(" ")	
            
                amplitude = float(cols[colAmpl])
                echowidth = float(cols[colEW])
            
            # calculate y position on curve based on x (=echowidth) and compare to amplitude
                curveval_left = funcLeft(echowidth, *popt)
                curveval_right = funcRight(echowidth, *popt_mirr)
                curveval_trans = funcRight(echowidth, *popt_mirr_shft)
            
            # check if echo width and amplitude are within prob. area
                if amplitude < curveval_left and amplitude < curveval_right: # terrain probability is 95%
                    cols.append("0.95")
                    f.write(" ".join(cols) + "\n")
		
                elif amplitude < curveval_trans: # transition zone, terrain probability is 5%
                    cols.append("0.05")
                    f.write(" ".join(cols) + "\n")
				
                else:
                    cols.append("0.0")
                    f.write(" ".join(cols) + "\n")
 			
                c+=1	
                progress=int(c / linecount * 100)
                if progress>p:
                    p+=5
                    print("\rAdding terrain probability to point cloud file: %i%% done" % (progress),)

    print("\rTerrain probability written to new point cloud file: %s" % outfile)

# duration of process
    endtime = time.time()
    runtime = endtime - starttime
    print("\nFinished script process after %i sec\n" % int(runtime))

	
if __name__ == "__main__":
  			main()
