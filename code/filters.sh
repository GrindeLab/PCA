#!/bin/bash

chr=$1

invcf=cg1_phs000951_TOPMed_WGS_COPDGene_freeze.5b.chr${chr}.pass_and_fail.gtonly.minDP0.hg38.vcf.gz
outdir=vcf/

## biallelic snps: -m2 -M2 -v snps
## pass filtering: -f PASS
## minor allele count at least 1: -c 1:minor
bcftools view -m2 -M2 -v snps -f PASS -c 1:minor $invcf -Oz -o ${outdir}filtered_freeze5_chr${chr}.vcf.gz
