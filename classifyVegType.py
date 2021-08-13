import sys
import os

infile="02_intermediate/ALS_all_echotypes_SOR_terrain.txt"
l=0	#counter for lines

outfile="02_intermediate/ALS_all_echotypes_SOR_terrain_classified.txt"
with open(infile,"r") as ifo:
	with open(outfile,"w") as ofo:
		header=True
		for line in ifo:
			if header:
				ofo.write(line)
				header=False
				continue
			vals=line.strip().split("\t")
			x=float(vals[0])
			y=float(vals[1])
			z=float(vals[2])
			ampl=int(float(vals[3]))
			ew=float(vals[4])
			et=int(vals[5])
			terrprob=float(vals[6])
			nz=float(vals[7])
			classid=int(vals[8])
			strip=int(vals[9])
			
			# calculate echo type according to las spec
			# note: this overwrites class[ground], but makes sense for these nZ (>50 cm)
			if (nz <= 2.0) and (nz > 0.5):
				classid=3
			elif (nz <= 5.0) and (nz > 2.0):
				classid=4
			elif (nz > 5.0):
				classid=5
			elif classid!=2:
				classid=1
					
			outstrings = [str(round(x,3)),str(round(y,3)),str(round(z,3)),str(ampl),str(round(ew,1)),str(et),str(round(terrprob,2)),str(round(nz,3)),str(classid),str(strip)]
			outline = "\t".join(outstrings)
			ofo.write(outline + "\n")
			
			l+=1
			
			if l%100000==0:
				print("\r%i lines processed" % (l),)

print("\r%i lines processed - done!" % (l))				