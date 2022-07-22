# Code Example

Here we provide an overview of the steps taken to run PCA in whole genome sequence data, using our analysis of TOPMed COPDGene data as an example.
This code leans heavily on the University of Washington Genetic Analysis Center's TOPMed Analysis Pipeline: https://github.com/UW-GAC/analysis_pipeline.

The analysis can be broken into five steps:

1. Filter
2. Convert VCF to GDS
3. Find unrelated samples
4. Optional: run ADMIXTURE 
5. Run PCA

## Setup

Before you begin, you will need to download/install the following:

- the TOPMed Analysis Pipeline (and its associated R packages and software --- see https://github.com/UW-GAC/analysis_pipeline)
- ADMIXTURE

You may also need to install or update various R packages (e.g., gdsfmt, SNPRelate, SeqArray, argparser, SeqVarTools, dplyr, tidyr, ggplot2, RColorBrewer) although some of this will be taken care of by running the `install_packages.R` script provided in the TOPMed Analysis Pipeline. 

## Filter

We used `bcftools` to restrict our analyses to biallelic single nucleotide variants. 

- `step1_filter.sh`


## Convert VCF to GDS

We then converted the filtered VCF file produced by `bcftools` to GDS format so that we could use the TOPMed Analysis Pipeline for the remaining steps. 

- `step2_vcf2gds.sh`

## Find Unrelated Samples

## Optional: Run ADMIXTURE

## Run PCA
