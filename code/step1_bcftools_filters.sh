#!/bin/bash

chr=$1          # chr num (1 -22)
inprefx=$2      # input VCF file name before chr num
inpostfx=$3     # input VCF file name after chr num
outprefx=$4     # output VCF file name before "_chr${chr}.vcf.gz" 

## set up input and output file names
in=${inprefx}${chr}${inpostfx}
out=${outprefx}_chr${chr}.vcf.gz

## filter using bcftools
## biallelic snps: -m2 -M2 -v snps
## pass filtering: -f PASS
## minor allele count at least 1: -c 1:minor
bcftools view -m2 -M2 -v snps -f PASS -c 1:minor $in -Oz -o $out
