#!/bin/bash

qsub -l h_vmem=8000M -N combine_variants -j y -cwd  -v R_LIBS=R_library -q b-students.q -S /bin/sh analysis_pipeline-master/runRscript.sh analysis_pipeline-master/R/combine_variants.R config/admixture_combine_variants.config --version 2.2.0
