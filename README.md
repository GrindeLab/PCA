# PCA

This repository contains code and other resources associated with the manuscript:

Grinde, K., Browning, B., Reiner, A., Thornton, T., Browning, S. "Adjusting for principal components can induce spurious associations in genome-wide association studies in admixed populations." *In preparation.*

If you use any of these resources, please cite our paper.

Of particular interest may be the following directories:

- `code`
- `data/highLD`

## `code`

This directory contains an example of the code we used to perform PCA, as well as associated pre-processing steps (e.g., LD pruning) and diagnostics (plotting SNP loadings), in TOPMed COPDGene whole genome sequence data. 

Our analysis leans heavily on the [UW GAC TOPMed Analysis Pipeline](https://github.com/UW-GAC/analysis_pipeline).

## `data/highLD`

This directory contains a list of high LD regions (identified via an extensive literature review) that are often recommended for exclusion prior to running PCA. 
Lists are available in builds 36 (`exclude_b36.txt`), 37 (`exclude_b37.txt`), and 38 (`exclude_b38.txt`).
See Table 1 in our paper for more details.

