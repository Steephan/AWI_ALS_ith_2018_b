import sys
import os

infile="02_intermediate/ALS_all_echotypes_SOR_lotsofdigits.txt"
outfile="02_intermediate/ALS_all_echotypes_SOR.txt"
l=0
with open(infile,"r") as ifo:
	with open(outfile,"w") as ofo:
		for line in ifo:

			vals=line.strip().split(" ")
			x=str(round(float(vals[0]),3))
			y=str(round(float(vals[1]),3))
			z=str(round(float(vals[2]),3))
			amp=str(round(float(vals[3]),1))
			ew=str(round(float(vals[4]),1))
			
			newvals=[x,y,z,amp,ew,vals[5],vals[6]]
			newline=" ".join(newvals)
			ofo.write(newline+"\n")
			
			l+=1
			if l%50000==0:
				print("\r%i lines reformatted..." % (l),)
				
print("\r%i lines reformatted... Done!" % (l))