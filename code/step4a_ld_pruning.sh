#!/bin/bash

qsub -terse -t 1-22 -l h_vmem=64000M -N ld_pruning -j y -cwd  -v R_LIBS=R_library -q b-students.q -S /bin/sh -m e analysis_pipeline-master/runRscript.sh -c analysis_pipeline-master/R/ld_pruning_myregions.R config/admixture_ld_pruning.config --version 2.2.0

