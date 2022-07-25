# Code Example

Here we provide an overview of the steps taken to run PCA in whole genome sequence data, using our analysis of TOPMed COPDGene data ([dbGaP accession: phs000951](https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000951.v5.p5)) as an example.
Our code leans heavily on the University of Washington Genetic Analysis Center's TOPMed Analysis Pipeline: https://github.com/UW-GAC/analysis_pipeline.

The analysis can be broken into five steps:

1. Filter
2. Convert VCF to GDS
3. Find unrelated samples
4. Optional: run ADMIXTURE 
5. Run PCA

## Setup

Before you begin, you will need to download/install the following:

- the TOPMed Analysis Pipeline, including all associated R packages and software --- see https://github.com/UW-GAC/analysis_pipeline
- ADMIXTURE (if you want to estimate admixture proportions as well as running PCA; otherwise skip this) --- see https://dalexander.github.io/admixture/ 

You may also need to install or update various R packages (e.g., gdsfmt, SNPRelate, SeqArray, argparser, SeqVarTools, dplyr, tidyr, ggplot2, RColorBrewer) although much of this should be taken care of by running the `install_packages.R` script provided in the TOPMed Analysis Pipeline. 

## `step1_filter.sh`

First, we used `bcftools` to filter the original VCF files (one per chromosome) to keep variants that:

- are biallelic SNPs (`-m2 -M2 -v snps`)
- pass filtering (`-f PASS`)
- have a minor allele count of at least 1 (`-c 1:minor`)

If running this step on your own dataset, the `filters.sh` script can/should be modified to:

- update the name of the VCF files (see `invcf` on line 5)
- update the name of the output VCF (see `outvcf` on line 6) 
- add/remove filters (see the `bcftools` documentation)

*Note that `bcftools` will need to be installed prior to running this step. 
If you installed all of the software associated with the TOPMed Analysis Pipeline, you should have done this already.*


## Convert VCF to GDS

We then converted the filtered VCF file produced by `bcftools` to GDS format (required by the TOPMed Analysis Pipeline): 

- `step2_vcf2gds.sh`

## Find Unrelated Samples

Next, we used two rounds of the iterative procedure proposed by [Conomos et al.](https://www.sciencedirect.com/science/article/pii/S0002929715004930) to identify a subset of mutually unrelated individuals.
This procedure is implemented by the TOPMed Analysis Pipeline.
For us, the process looked like this:
 
- run KING to get initial kinship estimates: `step3a_king.sh`
- run PC-AiR to find unrelated samples: `step3b_pcair_1.sh`
- run PCRelate to update kinship estimates: `step3c_pcrelate_1.sh`
- run PC-AiR again to find unrelated samples: `step3d_pcair_2.sh`

You could continue this process, iterating between PC-AiR and PCRelate, but we stopped after just two rounds.
See Conomos et al. for recommendations.


## Optional: Run ADMIXTURE

The COPDGene study includes both African Americans and European Americans, but self-identified race/ethnicity information was not provided with our dbGaP download.
To identify and restrict our analyses to African American samples only, we performed an unsupervised ADMIXTURE analysis.
This step could be skipped depending on the dataset you are working with, so we provide just a brief overview of the steps here:

- run LD pruning on each chromosome: `step4a_ld_pruning.sh`
- combine list of LD-pruned variants into a single file: `step4b_combine_variants.sh`
- convert to PLINK format: `step4c_gds2bed.sh`
- run ADMIXTURE: `step4d_admixture.sh`

Based on these estimated admixture proportions (using K = 2), we created a vector containing the IDs of individuals we hypothesized to be African American.
We saved this vector as `admixture_proportions/AA_admixture_unsup_K2.RData` so that we could restrict later analyses to this subset only.
 

## Run PCA

To conclude, we again used the TOPMed Analysis Pipeline to run PCA (with and without LD pruning and filtering) and check SNP loadings. 
This step consisted of the following:

- create `.config` files for TOPMed Analysis Pipeline: `step5a_create_config.sh`
- run PCA (and LD pruning and filtering) using SNPRelate: `step5b_snprelate.sh`
- calculate SNP loadings for each set of PCs: `step5c_snp_loadings.sh`
- plot SNP loadings: `step5d_plot_snp_loadings.sh`



