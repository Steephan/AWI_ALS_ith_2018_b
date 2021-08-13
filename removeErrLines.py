import sys
import os

filelist=os.listdir("01_pointclouds")
b=0	#counter for broken lines

for f in filelist:
	if f[0]=="x":
		infile="pointclouds/" + f
		outfile="pointclouds/repaired/" + f
		with open(infile,"r") as ifo:
			with open(outfile,"w") as ofo:
				header=True
				for line in ifo.readlines():
					if header:
						header=False
						continue
					vals=line.strip().split(";")
					if len(vals)==10:
						ofo.write(line)
					else:
						b+=1
		print("%i broken lines in %s" % (b,f))