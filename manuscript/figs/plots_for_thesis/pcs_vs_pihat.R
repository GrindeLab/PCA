
projdir <- '/projects/thornton/Lisa_Admixture_Mapping/'
covdir <- paste0(projdir, 'results/covariates/')
plotdir <- paste0(projdir, 'results/plots/for_thesis/')


## pihat
pihat <- read.table(paste0(covdir, 'covar_pi.txt'), header = F, stringsAsFactors = F)
names(pihat) <- c('ID1', 'ID2', 'pihat')

## PCs
pc_none <- read.table(paste0(covdir, 'pcs_4/pca_snprelate_exclude_none_prune_1_0.5.txt'), header = F, stringsAsFactors = F)
names(pc_none) <- c('ID1', 'ID2', 'PC1_none', 'PC2_none', 'PC3_none', 'PC4_none')

pc_prune <- read.table(paste0(covdir, 'pcs_4/pca_snprelate_exclude_none_prune_0.1_0.5.txt'), header = F, stringsAsFactors = F)
names(pc_prune) <- c('ID1', 'ID2', 'PC1_prune', 'PC2_prune', 'PC3_prune', 'PC4_prune')

pc_excl <- read.table(paste0(covdir, 'pcs_4/pca_snprelate_exclude_lit_prune_1_0.5.txt'), header = F, stringsAsFactors = F)
names(pc_excl) <- c('ID1', 'ID2', 'PC1_exclude', 'PC2_exclude', 'PC3_exclude', 'PC4_exclude')

pc_both <- read.table(paste0(covdir, 'pcs_4/pca_snprelate_exclude_lit_prune_0.1_0.5.txt'), header = F, stringsAsFactors = F)
names(pc_both) <- c('ID1', 'ID2', 'PC1_both', 'PC2_both', 'PC3_both', 'PC4_both')


## combine
library(dplyr)
dat <- pihat %>%
	inner_join(pc_none, by = c('ID1', 'ID2')) %>%
	inner_join(pc_prune, by = c('ID1', 'ID2')) %>%
	inner_join(pc_excl, by = c('ID1', 'ID2')) %>%
	inner_join(pc_both, by = c('ID1', 'ID2'))


## wide to long
library(tidyr)
dat.long <- gather(dat, "PC", "value", -ID1, -ID2, -pihat)
dat.long <- dat.long %>%
	mutate(PCnum = unlist(lapply(strsplit(PC, '_'), function(x) x[[1]]))) %>%
	mutate(filter = unlist(lapply(strsplit(PC, '_'), function(x) x[[2]])))
dat.long$PC <- NULL
dat.long <- dat.long %>%
	mutate(filter = factor(filter, levels = c('none', 'exclude', 'prune', 'both'), 
		labels = c('none', 'exclude', 'prune', 'both')))

## plot
library(ggplot2)
p <- ggplot(data = dat.long, aes(x = pihat, y = value)) + 
	geom_point() + 
	facet_grid(PCnum ~ filter, scales = 'free')+
	theme_bw()+
	xlab('Estimated admixture proportion') +
	ylab('Principal component') +
	theme(panel.spacing = unit(1.5, "lines"))

ggsave(filename = paste0(plotdir,'pcs_vs_pihat.png'), plot = p)
