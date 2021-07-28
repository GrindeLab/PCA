args <- commandArgs(TRUE)
EXCLUDE <- as.logical(args[[1]]) # TRUE, FALSE
LDTHRESH <- as.numeric(args[[2]]) # 1 (= no pruning), 0.2, 0.1
WDW.mb <- as.numeric(args[[3]]) # 0.5, 10
WDW.bp <- WDW.mb *  1000000

## Setup
proj.dir <- '/projects/thornton/Lisa_Admixture_Mapping/'

## Load GDS file
cat('........Opening GDS file \n')
library(gdsfmt, lib.loc = '/home/students/grindek/Rlib/')
library(SNPRelate, lib.loc = '/home/students/grindek/Rlib/')
g <- snpgdsOpen(paste0(proj.dir, 'geno/WHI_AA.gds'))


## Load list of unrelated samples
cat('\n........Excluding relatives \n')
unrel.fname <- paste0(proj.dir, 'spurious_assoc/results/unrelated/pcair_3rd_AA.txt')
unrel <- read.table(unrel.fname, header = F, stringsAsFactors = F)
samp.keep <- unrel$V1
cat('...Keeping', length(samp.keep), 'samples \n')


## Set default snp.keep
snp.keep <- read.gdsn(index.gdsn(g, 'snp.id'))
cat('...Starting with', length(snp.keep), 'SNPs \n')


## Filter out high LD regions
if(EXCLUDE){
 cat('\n........Excluding high LD regions \n')
 filt.dir <- '/projects/browning/brwnlab/kelsey/spurious_assoc/highLD_regions/'
 filt <- read.table(paste0(filt.dir, 'exclude.txt'), stringsAsFactors = F)
 names(filt) <- c('chrom','start.base','end.base','comment')
 source(paste0(filt.dir, 'filterHighLD.R'))
 snp.keep <- filterHighLD.geno(gds = g, filt = filt, verbose = FALSE)
 cat('...Reducing to', length(snp.keep), 'SNPs after exclusions \n')
}


## Run LD pruning
if(LDTHRESH < 1){
 cat('\n........Running LD pruning with threshold =', LDTHRESH, 'and window size =', WDW.bp, '\n')
 snpset <- snpgdsLDpruning(g, sample.id = samp.keep, snp.id = snp.keep, ld.threshold = LDTHRESH, slide.max.bp = WDW.bp)
 snp.keep <- unlist(snpset)
 cat('...Reducing to', length(snp.keep), 'SNPs after LD pruning \n')
}


## Run PCA
cat('\n........Running PCA\n')
pca <- snpgdsPCA(g, sample.id = samp.keep, snp.id = snp.keep, num.thread = 2)
pca.df <- data.frame(sample.id = pca$sample.id,
               sample.id2 = pca$sample.id,
               EV1 = pca$eigenvect[,1],
               EV2 = pca$eigenvect[,2],
               EV3 = pca$eigenvect[,3],
               EV4 = pca$eigenvect[,4],
               EV5 = pca$eigenvect[,5],
               EV6 = pca$eigenvect[,6],
               EV7 = pca$eigenvect[,7],
               EV8 = pca$eigenvect[,8],
               EV9 = pca$eigenvect[,9],
               EV10 = pca$eigenvect[,10],
               stringsAsFactors = FALSE)

## print percent of variance explained
cat('...Percent of variance explained by each PC: \n')
pc.percent <- pca$varprop*100
head(round(pc.percent, 2), 10)

## Create covariate files for running PLINK
cat('\n........Saving PCs as PLINK covar files \n')
pc.dir <- paste0(proj.dir, 'spurious_assoc/results/PCs/pc')
pc.fname <- paste0('snprelate_exclude_', EXCLUDE, '_prune_r', LDTHRESH, '_w', WDW.mb)
write.table(pca.df, file = paste0(pc.dir, '10/', pc.fname, '.txt'), quote = F, row.names = F, col.names = F)
write.table(pca.df[,1:6], file = paste0(pc.dir, '4/', pc.fname, '.txt'), quote = F, row.names = F, col.names = F)
write.table(pca.df[,1:3], file = paste0(pc.dir, '1/', pc.fname, '.txt'), quote = F, row.names = F, col.names = F)


## Get corr between PCs and genotypes
cat('\n........Calculating correlation between PCs and genotypes \n')
pca.geno.corr <- snpgdsPCACorr(pca, g, eig.which = 1:10)
save(pca.geno.corr, file = paste0(proj.dir, 'spurious_assoc/results/PC_geno_corr/', pc.fname, '.RData'))


## Get corr between PCs and local ancestry
cat('\n........Calculating correlation between PCs and local anc \n')
la <- snpgdsOpen(paste0(proj.dir, 'orig_files/WHI_AA_LOCAL.gds'))
pca.la.corr <- snpgdsPCACorr(pca, la, eig.which = 1:10)
save(pca.la.corr, file = paste0(proj.dir, 'spurious_assoc/results/PC_anc_corr/', pc.fname, '.RData'))


## Get SNP loadings
cat('\n........Calculating SNP loadings \n')
snpload <- snpgdsPCASNPLoading(pca, g)
save(snpload, file = paste0(proj.dir, 'spurious_assoc/results/PC_loadings/', pc.fname, '.RData'))

## Close GDS files
cat('\n........Closing GDS files \n')
snpgdsClose(g)
snpgdsClose(la)

