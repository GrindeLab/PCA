#!/bin/bash

chr=$1         # chr num
sub1prefx=$2   # name of subset 1 VCF before "_chr${chr}.vcf.gz"
sub2prefx=$3   # name of subset 2 VCF before "_chr${chr}.vcf.gz"
outprefx=$4    # name of merged VCF before "_chr${chr}.vcf.gz"

## merge two datasets

zcat ${sub1prefx}_chr${i}.vcf.gz | grep "##" > header_filtered_chr${i}
zcat ${sub1prefx}_chr${i}.vcf.gz | grep -v "##" > chr${i}_sub1
zcat ${sub3prefx}_chr${i}.vcf.gz | grep -v "##" | cut -f10- > chr${i}_sub2

outvcf=${outprefx}_chr${i}.vcf
cat header_filtered_chr${i} > $outvcf
paste -d '\t' chr${i}_sub1 chr${i}_sub2 >> $outvcf

gzip $outvcf

## remove tmp files
rm chr${i}_sub1 chr${i}_sub2
rm header_filtered_chr${i}
