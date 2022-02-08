#!/bin/bash

rep=$1

qsub -q b-students.q -N manh_amap_$rep -pe local 2 -m e run_manh.sh $rep amap
qsub -q b-students.q -N manh_gwas_$rep -pe local 2 -m e run_manh.sh $rep gwas
