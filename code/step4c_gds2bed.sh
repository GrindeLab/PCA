#!/bin/bash

gds=gds/filtered_freeze5.gds #$1
samp=data/round2_unrelated.RData #$2
snp=data/admixture_pruned_variants.RData #$3
bed=plink/filtered_freeze5 #$4

## convert GDS files into PLINK format
qsub -q b-students.q -N gds2bed -m e -pe local 4 run_gds2bed.sh $gds $samp $snp $bed
