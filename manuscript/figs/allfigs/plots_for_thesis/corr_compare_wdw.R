mylib <- '/home/students/grindek/Rlib/'

## getobj function
getobj <- function(Rdat){
  obj <- load(Rdat)
  eval(parse(text = obj))
}

## directory setup
projdir <- '/projects/thornton/Lisa_Admixture_Mapping/'
corrdir <- paste0(projdir, 'results/pc_geno_corr/')
plotdir <- paste0(projdir, 'results/plots/for_thesis/')

## load correlation
corr_none <- getobj(paste0(corrdir, 'pca_snprelate_corr.RData'))
dat_none <- data.frame(t(corr_none$snpcorr[1:4,]))
names(dat_none) <- paste0('PC', 1:4, '_none')
dat_none$rsID <- corr_none$snp.id

#corr_excl <- getobj(paste0(corrdir, 'pca_snprelate_exclude_lit_prune_1_0.5_corr.RData'))
#dat_excl <- data.frame(t(corr_excl$snpcorr[1:4,]))
#names(dat_excl) <- paste0('PC', 1:4, '_exclude')
#dat_excl$rsID <- corr_excl$snp.id

corr_prune05 <- getobj(paste0(corrdir, 'pca_snprelate_prune_0.1_0.5_corr.RData'))
dat_prune05 <- data.frame(t(corr_prune05$snpcorr[1:4,]))
names(dat_prune05) <- paste0('PC', 1:4, '_prune0.5')
dat_prune05$rsID <- corr_prune05$snp.id

#corr_both <- getobj(paste0(corrdir, 'pca_snprelate_exclude_lit_prune_0.1_0.5_corr.RData'))
#dat_both <- data.frame(t(corr_both$snpcorr[1:4,]))
#names(dat_both) <- paste0('PC', 1:4, '_both')
#dat_both$rsID <- corr_both$snp.id

corr_prune2 <- getobj(paste0(corrdir, 'pca_snprelate_prune_0.1_2_corr.RData'))
dat_prune2 <- data.frame(t(corr_prune2$snpcorr[1:4,]))
names(dat_prune2) <- paste0('PC', 1:4, '_prune2')
dat_prune2$rsID <- corr_prune2$snp.id

corr_prune10 <- getobj(paste0(corrdir, 'pca_snprelate_prune_0.1_10_corr.RData'))
dat_prune10 <- data.frame(t(corr_prune10$snpcorr[1:4,]))
names(dat_prune10) <- paste0('PC', 1:4, '_prune10')
dat_prune10$rsID <- corr_prune10$snp.id


## load chrom and position info
library(gdsfmt, lib.loc = mylib)
g <- openfn.gds(paste0(projdir, 'geno/WHI_AA.gds'))
snp.id <- read.gdsn(index.gdsn(g, 'snp.id'))
snp.pos <- read.gdsn(index.gdsn(g, 'snp.position'))
snp.chr <- read.gdsn(index.gdsn(g, 'snp.chromosome'))
snp.dat <- data.frame(rsID = snp.id, pos = snp.pos, chr = snp.chr)
closefn.gds(g)

## combine
library(dplyr)
dat <- snp.dat %>%
	inner_join(dat_none, by = 'rsID') %>%
#	inner_join(dat_excl, by = 'rsID') %>%
	inner_join(dat_prune05, by = 'rsID') %>%
#	inner_join(dat_both, by = 'rsID')
	inner_join(dat_prune2, by = 'rsID') %>%
	inner_join(dat_prune10, by = 'rsID')

## wide to long
library(tidyr)
dat.long <- gather(dat, "PC", "corr", -rsID, -pos, -chr)
dat.long <- dat.long %>%
	mutate(corr=abs(corr)) %>%
	mutate(chr=factor(chr)) %>%
	mutate(PCnum = factor(unlist(lapply(strsplit(PC, '_'), function(x) x[[1]])))) %>%
	mutate(filter = factor(unlist(lapply(strsplit(PC, '_'), function(x) x[[2]])), 
		levels = c('none', 'prune0.5', 'prune2', 'prune10'),
		labels = c('none', 'prune0.5', 'prune2', 'prune10')))
dat.long$PC <- NULL

## set up colors for plotting
library(RColorBrewer)
chr <- levels(dat.long$chr)
cmap <- setNames(rep_len(brewer.pal(8, "Dark2"), length(chr)), chr)

## plot
library(ggplot2)
#filters <- levels(dat.long$filter)
#bins <- list(c('none', 'exclude'), c('prune', 'both'))
#for(i in 1:2){
#	dat <- subset(dat.long, filter %in% bins[[i]])
	dat <- dat.long
	p <- ggplot(dat, aes(chr, corr, group = interaction(chr, pos), color = chr)) +
		geom_point(position = position_dodge(0.8)) + 
		facet_grid(PCnum ~ filter, scales = 'free') + 
		scale_color_manual(values = cmap, breaks = names(cmap)) +
		ylim(0,1) + 
		theme_bw() +
		theme(legend.position = 'none') +
		xlab('Chromosome') + 
		ylab('abs(Correlation)') +
		theme(text = element_text(size = 20)) + 
		theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 12))
	ggsave(paste0(plotdir, 'pc_geno_corr_compare_window.png'), plot = p, width = 15, height = 15)
#	ggsave(paste0(plotdir, 'pc_geno_corr_', i, '.png'), plot = p, width = 15, height = 15)
#	ggsave(paste0(plotdir, 'pc_geno_corr_', filters[i], '.png'), plot = p, width = 10, height = 15)
}
