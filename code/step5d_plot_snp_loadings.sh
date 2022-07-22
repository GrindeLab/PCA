#!/bin/bash

## create plots
##   ./step5d_plot_snp_loadings.sh config/prune_TRUE_0.1_0.5_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_FALSE_1_0_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_FALSE_0.05_0.5_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_FALSE_0.1_0.5_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_FALSE_0.1_10_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_FALSE_0.2_0.5_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_FALSE_1_0_0_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_TRUE_0.05_0.5_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_TRUE_0.1_10_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_TRUE_0.2_0.5_0.01_pca_load_plots.config
##   ./step5d_plot_snp_loadings.sh config/prune_TRUE_1_0_0.01_pca_load_plots.config


config=$1 
pipeline=analysis_pipeline-master/

qsub -terse -N plot_load -j y -cwd -v R_LIBS=R_library -q b-students.q -S /bin/sh -pe local 2 ${pipeline}/runRscript.sh ${pipeline}/R/snprelate_loadings_plots.R $config --version 2.2.0

