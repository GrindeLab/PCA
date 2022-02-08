mylib <- '/home/students/grindek/Rlib/'

## getobj function
getobj <- function(Rdat){
  obj <- load(Rdat)
  eval(parse(text = obj))
}

## directory setup
projdir <- '/projects/thornton/Lisa_Admixture_Mapping/'
loaddir <- paste0(projdir, 'results/pca_snp_loadings/')
plotdir <- paste0(projdir, 'results/plots/for_thesis/')

## load loadings
load_none <- getobj(paste0(loaddir, 'pca_snprelate_prune_1_0.5_loadings.RData'))
dat_none <- data.frame(t(load_none$snploading[1:4,]))
names(dat_none) <- paste0('PC', 1:4, '_none')
dat_none$rsID <- load_none$snp.id

load_excl <- getobj(paste0(loaddir, 'pca_snprelate_exclude_lit_prune_1_0.5_loadings.RData'))
dat_excl <- data.frame(t(load_excl$snploading[1:4,]))
names(dat_excl) <- paste0('PC', 1:4, '_exclude')
dat_excl$rsID <- load_excl$snp.id

load_prune2 <- getobj(paste0(loaddir, 'pca_snprelate_prune_0.2_0.5_loadings.RData'))
dat_prune2 <- data.frame(t(load_prune2$snploading[1:4,]))
names(dat_prune2) <- paste0('PC', 1:4, '_prune0.2')
dat_prune2$rsID <- load_prune2$snp.id

load_prune1 <- getobj(paste0(loaddir, 'pca_snprelate_prune_0.1_10_loadings.RData'))
dat_prune1 <- data.frame(t(load_prune1$snploading[1:4,]))
names(dat_prune1) <- paste0('PC', 1:4, '_prune0.1')
dat_prune1$rsID <- load_prune1$snp.id


## load chrom and position info
library(gdsfmt, lib.loc = mylib)
g <- openfn.gds(paste0(projdir, 'geno/WHI_AA.gds'))
snp.id <- read.gdsn(index.gdsn(g, 'snp.id'))
snp.pos <- read.gdsn(index.gdsn(g, 'snp.position'))
snp.chr <- read.gdsn(index.gdsn(g, 'snp.chromosome'))
snp.dat <- data.frame(rsID = snp.id, pos = snp.pos, chr = snp.chr, stringsAsFactors = F)
closefn.gds(g)

## combine
library(dplyr)
dat <- snp.dat %>%
	inner_join(dat_none, by = 'rsID') %>%
	inner_join(dat_excl, by = 'rsID') %>%
	inner_join(dat_prune2, by = 'rsID') %>%
	inner_join(dat_prune1, by = 'rsID')
	#inner_join(dat_both, by = 'rsID')


## wide to long
library(tidyr)
dat.long <- gather(dat, "PC", "load", -rsID, -pos, -chr)
dat.long <- dat.long %>%
	mutate(load=abs(load)) %>%
	mutate(chr=factor(chr)) %>%
	mutate(PCnum = factor(unlist(lapply(strsplit(PC, '_'), function(x) x[[1]])))) %>%
	mutate(filter = factor(unlist(lapply(strsplit(PC, '_'), function(x) x[[2]])), 
		levels = c('none', 'exclude', 'prune0.2', 'prune0.1'),
		labels = c('none', 'exclude', 'prune0.2', 'prune0.1')))
dat.long$PC <- NULL

## set up colors for plotting
library(RColorBrewer)
chr <- levels(dat.long$chr)
cmap <- setNames(rep_len(brewer.pal(8, "Dark2"), length(chr)), chr)

## plot
library(ggplot2)

## plot naive
dat.naive <- snp.dat %>%
		inner_join(dat_none, by = 'rsID')
dat.naive <- gather(dat.naive, "PC", "load", -rsID, -pos, -chr)
dat.naive <- dat.naive %>%
	mutate(load = abs(load)) %>%
	mutate(chr = factor(chr)) %>%
	mutate(PCnum = factor(unlist(lapply(strsplit(PC, '_'), function(x) x[[1]]))))
p.naive <- ggplot(dat.naive, aes(chr, load, group = interaction(chr, pos), color = chr)) +
	geom_point(position = position_dodge(0.8)) +
	facet_grid(PCnum ~ ., scales = 'fixed') +
	scale_color_manual(values = cmap, breaks = names(cmap)) +
	theme_bw() + 
	theme(legend.position = 'none') +
	xlab('Chromosome') +
	ylab('abs(Loadings)') +
	theme(text = element_text(size = 20)) +
	theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 12))
ggsave(paste0(plotdir, 'pc_naive_load.png'), plot = p.naive, width = 6, height = 10)

##filters <- levels(dat.long$filter)
##bins <- list(c('none', 'exclude'), c('prune', 'both'))
##for(i in 1:2){
#	dat <- subset(dat.long, filter %in% bins[[i]])
#	dat <- dat.long
#	p <- ggplot(dat, aes(chr, load, group = interaction(chr, pos), color = chr)) +
#		geom_point(position = position_dodge(0.8)) + 
#		facet_grid(PCnum ~ filter, scales = 'fixed') + 
#		scale_color_manual(values = cmap, breaks = names(cmap)) +
#		#ylim(0,1) + 
#		theme_bw() +
#		theme(legend.position = 'none') +
#		xlab('Chromosome') + 
#		ylab('Loadings') +
#		theme(text = element_text(size = 30)) + 
#		theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 12))
#	ggsave(paste0(plotdir, 'pc_compare_load.png'), plot = p, width = 15, height = 15)
##	ggsave(paste0(plotdir, 'pc_geno_corr_', i, '.png'), plot = p, width = 15, height = 15)
##	ggsave(paste0(plotdir, 'pc_geno_corr_', filters[i], '.png'), plot = p, width = 10, height = 15)
}
