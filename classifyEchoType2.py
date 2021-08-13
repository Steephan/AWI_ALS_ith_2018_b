import sys
import os

infile="02_intermediate/ALS2_all_basic.txt"
l=0	#counter for lines

outfile="02_intermediate/ALS2_all_echotypes.txt"
with open(infile,"r") as ifo:
	with open(outfile,"w") as ofo:
		header=False
		for line in ifo:
			if header:
				header=False
				continue
			vals=line.strip().split(" ")
			x=float(vals[0])
			y=float(vals[1])
			z=float(vals[2])
			ampl=float(vals[3])
			ew=float(vals[4])
			en=int(vals[5])
			ec=int(vals[6])
			er=int(vals[7])
			strip=int(vals[8])
			
			# calculate echo type
			if ec==1:
				echotype=0
			elif er==0:
				echotype=3
			elif en==1:
				echotype=1
			else:
				echotype=2

			outstrings = [str(round(x,3)),str(round(y,3)),str(round(z,3)),str(round(ampl,2)),str(round(ew,2)),str(echotype),str(strip)]
			outline = " ".join(outstrings)
			ofo.write(outline + "\n")
			
			l+=1
			
			if l%100000==0:
				print("\r%i lines processed" % (l),)

print("\r%i lines processed - done!" % (l))				