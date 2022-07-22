#!/bin/bash

## calculate SNP loadings
##   ./step5c_snp_loadings.sh config/prune_TRUE_0.1_0.5_0.01_pca_load.config  
##   ./step5c_snp_loadings.sh config/prune_FALSE_1_0_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_FALSE_0.05_0.5_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_FALSE_0.1_0.5_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_FALSE_0.1_10_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_FALSE_0.2_0.5_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_FALSE_1_0_0_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_TRUE_0.05_0.5_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_TRUE_0.1_10_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_TRUE_0.2_0.5_0.01_pca_load.config
##   ./step5c_snp_loadings.sh config/prune_TRUE_1_0_0.01_pca_load.config

config=$1 
pipeline=analysis_pipeline-master/

qsub -terse -l h_vmem=20000M -N pca_load -j y -cwd  -v R_LIBS=R_library -q b-students.q -S /bin/sh ${pipeline}/runRscript.sh ${pipeline}/R/pca_loadings.R $config --version 2.2.0


