import sys
import numpy

for line in sys.stdin:
	line = line.strip().split()
	chr=line[0]
	start=line[1]
	end=line[2]
	print(chr + '\t' + str(int(start)+1) + '\t' + str(int(end)+1) + '\t' + "\t".join(line[3:]))
