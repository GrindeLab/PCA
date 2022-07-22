#!/bin/bash

K=$1 # 2, 3
bed=plink/filtered_freeze5.bed

adir=admixture_linux-1.3.0

echo "${adir}/admixture $bed $K" | qsub -q b-students.q -N admixture_K$K -m e 
 
