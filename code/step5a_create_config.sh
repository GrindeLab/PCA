#!/bin/bash

## create config files for LD pruning
Rscript create_config.R

## create config files for calculating SNP loadings
Rscript create_config_loadings.R

## create config files for plotting SNP loadings
Rscript create_config_plot_loadings.R
