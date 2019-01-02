import sys
import numpy 
import math
'''
modified from XXX

'''
gene_list = []
gene_dict = {}

for line in sys.stdin:
  line = line.strip().split()
  gene = line[3]
  if line[3] in gene_dict:
    gene_dict[gene][3] += int(line[6])-int(line[5])
    gene_dict[gene][4] += (int(line[6])-int(line[5]))*math.pow(2,float(line[7]))
  else:
    gene_list.append(gene)
    if line[4] == ".":
      gene_dict[gene] = [line[0], line[1], line[2], "NA", "NA"]
    else:
      gene_dict[gene] = [line[0], line[1], line[2], int(line[6])-int(line[5]), (int(line[6])-int(line[5]))*math.pow(2,float(line[7]))]
'''
1-3 columns: region annotated by gene name in the bed file
4: length of the CNV segment
5: CNV length * segment mean value
'''

for gene in gene_list:
  if gene_dict[gene][3] == "NA":
    print(gene + '\t' + '\t'.join(gene_dict[gene][0:3]) + '\tNA')
  elif gene_dict[gene][4]/gene_dict[gene][3] == 0:
    print(gene + '\t' + '\t'.join(gene_dict[gene][0:3]) + '\t-Inf')
  else:
    print(gene + '\t' + '\t'.join(gene_dict[gene][0:3]) + '\t' + str(numpy.log2(numpy.array(gene_dict[gene][4]/gene_dict[gene][3]))))

