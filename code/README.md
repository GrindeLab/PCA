# Code Example

Here we provide an overview of the steps taken to run PCA in whole genome sequence data, using our analysis of TOPMed COPDGene data ([dbGaP accession: phs000951](https://www.ncbi.nlm.nih.gov/projects/gap/cgi-bin/study.cgi?study_id=phs000951.v5.p5)) as an example.
Our code leans heavily on the University of Washington Genetic Analysis Center's TOPMed Analysis Pipeline: https://github.com/UW-GAC/analysis_pipeline.

The analysis can be broken into five steps:

1. Filter variants
2. Convert VCF to GDS
3. Find unrelated samples
4. Optional: run ADMIXTURE 
5. Run PCA (after LD pruning) and inspect SNP loadings

## Setup

### TOPMed Analysis Pipeline

Before you begin, you will need to download/install the TOPMed Analysis Pipeline, including all associated R packages and software --- see https://github.com/UW-GAC/analysis_pipeline

The code in our `analysis-pipeline-master` directory is taken directly from Version 2.2.0 of this pipeline, with the exception of two files that we created (`cluster_bstudents_cfg.json` and `ld_pruning_myregions.R`). 
A newer version of the pipeline may now be available.
In general, we recommend using the latest version --- just note that updates may be needed to the process outlined below depending on what changes have been made to the analysis pipeline.


### `ADMIXTURE`

If you want to estimate admixture proportions in addition to running PCA, you should download a program such as [`ADMIXTURE`](https://dalexander.github.io/admixture/) or [`RFMix`](https://github.com/slowkoni/rfmix). 
We used an unsupervised `ADMIXTURE` analysis in our analysis of TOPMed COPDGene samples.


### R Pacakges

You may also need to install or update various R packages (e.g., gdsfmt, SNPRelate, SeqArray, argparser, SeqVarTools, dplyr, tidyr, ggplot2, RColorBrewer) although much of this should be taken care of by running the `install_packages.R` script provided in the TOPMed Analysis Pipeline. 


## Filter: `step1_filter.sh`

First, we use `bcftools` to filter the original VCF files (one per chromosome) to keep variants that:

- are biallelic SNPs (`-m2 -M2 -v snps`)
- pass filtering (`-f PASS`)
- have a minor allele count of at least 1 (`-c 1:minor`)

If running this step on your own dataset, the `filters.sh` script can/should be modified to:

- update the name of the VCF files (see `invcf` on line 5)
- update the name of the output VCF (see `outvcf` on line 6) 
- add or remove filters (see the `bcftools` documentation)

*Note that `bcftools` will need to be installed prior to running this step. 
If you installed all of the software associated with the TOPMed Analysis Pipeline, you should have done this already.*


## Convert VCF to GDS: `step2_vcf2gds.sh`

We then convert the filtered VCF file produced by Step 1 to GDS format, which is required by the TOPMed Analysis Pipeline.

If running this step on your own dataset, you can/should:

- update the location of the TOPMed Analaysis Pipeline directory (see `pipeline` on line 2)
- update the VCF to GDS configuration file (see `config/vcf2gds.config`) with the desired output prefix, input VCF file name, and output GDS file name 
- create your own cluster file (e.g., `cluster_bstudents_cfg.json`) and then update the `--cluster_file` option in the shell script (line 5) accordingly

See the TOPMed Analysis Pipeline documentation ([Basic outline](https://github.com/UW-GAC/analysis_pipeline#basic-outline) and [Conversion to GDS](https://github.com/UW-GAC/analysis_pipeline#conversion-to-gds)) for more details. 


## Find Unrelated Samples

Next, we use the iterative procedure proposed by [Conomos et al.](https://www.sciencedirect.com/science/article/pii/S0002929715004930) to identify a subset of mutually unrelated individuals.
This procedure is implemented by the TOPMed Analysis Pipeline and is split into multiple sub-steps.
See the [Relatedness and Population structure](https://github.com/UW-GAC/analysis_pipeline#relatedness-and-population-structure) section of the TOPMed Analaysis Pipeline documentation for more details.


### `step3a_king.sh`

Run `KING` to get initial kinship estimates.

When running this step on your own dataset, you can/should update:

- the location of the TOPMed Analaysis Pipeline directory (see `pipeline` on line 2)
- the configuration file (`config/king.config`)
- the name of the `--cluster file` (line 5)

*Note that `KING` will need to be installed prior to running this step.
If you installed all of the software associated with the TOPMed Analysis Pipeline, you should have done this already.*


### `step3b_pcair_1.sh`

Run `PC-AiR` to find unrelated samples.

As above, you will need to update:

- the location of the pipeline (line 2)
- the configuration file (`config/pcair_round1.config`)
- the cluster file (line 5)


### `step3c_pcrelate_1.sh`

Run `PCRelate` to update kinship estimates.

Remember to update:

- the location of the pipeline (line 2)
- the configuration file (`config/pcrelate_round1.config`)
- the cluster file (line 5)

### `step3d_pcair_2.sh`

Run `PC-AiR` again to update list of unrelated samples.

Remember to update:

- the location of the pipeline (line 2)
- the configuration file (`config/pcair_round2.config`)
- the cluster file (line 5)

### Etc.

You could continue this process, iterating between PC-AiR and PCRelate, but two rounds is often sufficient.
See [Conomos et al.](https://www.sciencedirect.com/science/article/pii/S0002929715004930) for recommendations.


## Optional: Run ADMIXTURE

The COPDGene study includes both African Americans and European Americans, but self-identified race/ethnicity information was not provided with our dbGaP download.
To identify and restrict our analyses to African American samples only, we performed an unsupervised `ADMIXTURE` analysis.
Even if you are not interested in filtering individuals, you may also want to run `ADMIXTURE` so you can compare estimated global ancestry proportions to PCs.
Since this step is optional, we provide just a brief overview here.
See the `ADMIXTURE` documentation for more details.

### `step4a_ld_pruning.sh`

Run LD pruning on each chromosome.

You will need to update: 

- the location of the R library (`-v R_LIBS=`)
- the name of the queue (`-q`)
- the configuration file (`config/admixture_ld_pruning.config`)

Note that this step uses a customized version of the TOPMed Analysis Pipeline's LD pruning code so that we can filter additional high LD regions identified in an extensive literature review. 
See our `analysis_pipeline-master/R/ld_pruning_myregions.R` (and feel free to modify further if there are additional regions you would like to exclude).

### `step4b_combine_variants.sh` 

Step 4a creates separate lists of LD pruned variants per chromosome. 
Next, we combine these lists into a single file.

You will need to update: 

- the location of the R library (`-v R_LIBS=`)
- the name of the queue (`-q`)
- the configuration file (`config/admixture_combine_variants.config`)

### `step4c_gds2bed.sh`

The `ADMIXTURE` program requires that data be stored in PLINK format (rather than GDS). 
Our next step is to make this conversion.

You will need to update:

- the intput GDS (line 3)
- the list of unrelated samples from Step 3d (line 4)
- the list of LD-pruned variants from Step 4b (line 5)
- the output BED file (line 6)
- the name of the queue (`-q` on line 9)

### `step4d_admixture.sh`

Finally, we are ready to run `ADMIXTURE`.

You will need to update:

- the number of ancestral populations (line 3)
- the input BED file from Step 4c (line 4)
- the location of the ADMIXTURE program (line 6)

See the [`ADMIXTURE` documentation](https://dalexander.github.io/admixture/) for more options.

Based on the estimated admixture proportions produced by this step (using K = 2), we next created a vector containing the IDs of individuals we hypothesized to be African American.
We saved this vector as `admixture_proportions/AA_admixture_unsup_K2.RData` so that we could restrict later analyses to this subset only.
This step may not be necessary for your own dataset.
 

## Run PCA

At last, we are ready to run PCA.
We again use the TOPMed Analysis Pipeline, which additionally provides scripts to perform LD pruning and check SNP loadings.


### `step5a_create_config.sh`

First, we create `.config` files for LD pruning, calculating SNP loadings, and plotting SNP loadings.

The `create_config.R` script creates configuration files for LD pruning. 
We considered different combinations of four criteria:

- `excl`: `TRUE` (excluding high LD regions identified in the literature) or `FALSE` (no exclusions)
- `r2`: `1` (no LD pruning), `0.2` ($r^2$ threshold of 0.2), `0.1` ($r^2$ threshold of 0.1, `0.05` ($r^2$ threshold of 0.05)
- `win`: `0` (no LD pruning), `0.5` (window size of 0.5 Mb), `10` (window size of 10 Mb)
- `maf`: `0` (no filtering based on minor allele frequency), `0.01` (keep only variants with a MAF > 0.01)

Lines 3--14 set up a function that will create configuration files for different choices of filtering/pruning criteria. 
You will need to update this function to change:

- the input GDS (line 5)
- the genome bulid (line 6)
- the list of samples to include, such as only those admixed individuals identified in Step 4d (line 7)

Lines 17--35 then create configuration files using different combinations of filtering and pruning criteria.
You may update this to implement only the pre-processing you feel is appropriate for your dataset.


Two other scripts create configuration files to calculate (`create_config_loadings.R`) and plot (`create_config_plot_loadings.R`) SNP loadings for sets of PCs after different combinations of filtering and pruning.
Update lines 13--31 depending on the pre-processing choices you made in `create_config.R`.


### `step5b_snprelate.sh`

Next, we use the `SNPRelate` package to implement pre-processing (LD pruning and filtering) and then run principal component analysis.

You will need to update the cluster file (line 19) and then run this script on each of the PCA configuration files you created in Step 5a.


### `step5c_snp_loadings.sh`

After PCs have been calculated, we assess the contribution of each variant to each PC by examining SNP loadings.

You will need to update:

- the location of the R library (`-v R_LIBS=`)
- the name of the queue (`-q`)

Then, run this script on each of the SNP Loadings configuration files you created in Step 5a.


### `step5d_plot_snp_loadings.sh`

Finally, we plot these SNP loadings to investigate whether any PCs are capturing local genomic features rather than genome-wide ancestry.

Like Step 5c, you will need to update the location of the R library (`-v R_LIBS=`) and the name of the queue (`-q`), then run the script on the loading plot config files you created in Step 5a.

Carefully examine these plots to see if any of the PCs you are planning to include in GWAS models are highly correlated with SNPs on multiple chromosomes. 
If so, you may be at risk of inducing spurious associations due to collider bias. 
Consider using fewer PCs, an alternative measure of global ancestry (e.g., `ADMIXTURE` proportions), or re-run PCA with stricter LD pruning (smaller $r^2$ threshold and/or larger window size) and re-examine the resulting SNP loading plots.


