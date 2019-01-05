import sys
import numpy 
import math
'''
modified from a script of Steven Foltz

'''
gene_list = []
'''
list to store all the gene symbols
'''
gene_dict = {}
'''
dictionary to store for each gene, (1) chromosome, (2) gene start, (3) gene end, (4) bps of CNV segments overlapping this gene, (5) the sum of (length of CNV segment)*(log2(copy ratio)) of all the CNV segments overlapping this gene (usually just 1)
'''

for line in sys.stdin:
  line = line.strip().split()
'''
for each line of the input, the columns represent (1) chromosome, (2) gene start, (3) gene end, (4) gene symbol, (5) chromosome, (6) CNV start, (7) CNV end, (8) CNV log2(copy ratio).
'''
  gene = line[3]

  if line[3] in gene_dict:
'''if this gene has already overlapped with a CNV segment'''
    gene_dict[gene][3] += int(line[6])-int(line[5])
    gene_dict[gene][4] += (int(line[6])-int(line[5]))*math.pow(2,float(line[7]))
  else:
    gene_list.append(gene)
    if line[4] == ".":
'''if this gene have no overlap with any CNV segment for this .CNV file'''
      gene_dict[gene] = [line[0], line[1], line[2], "NA", "NA"]
    else:
      gene_dict[gene] = [line[0], line[1], line[2], int(line[6])-int(line[5]), (int(line[6])-int(line[5]))*math.pow(2,float(line[7]))]


for gene in gene_list:
  if gene_dict[gene][3] == "NA":
    print(gene + '\t' + '\t'.join(gene_dict[gene][0:3]) + '\tNA')
  elif gene_dict[gene][4]/gene_dict[gene][3] == 0:
    print(gene + '\t' + '\t'.join(gene_dict[gene][0:3]) + '\t-Inf')
  else:
    print(gene + '\t' + '\t'.join(gene_dict[gene][0:3]) + '\t' + str(numpy.log2(numpy.array(gene_dict[gene][4]/gene_dict[gene][3]))))

