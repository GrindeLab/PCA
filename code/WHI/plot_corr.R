args <- commandArgs(TRUE)
EXCLUDE <- as.logical(args[[1]]) # TRUE, FALSE
LDTHRESH <- as.numeric(args[[2]]) # 1 (= no pruning), 0.2, 0.1
WDW.mb <- as.numeric(args[[3]]) # 0.5, 10
n_perpage <- as.numeric(args[[4]]) # 4

## Setup
proj.dir <- '/projects/thornton/Lisa_Admixture_Mapping/spurious_assoc/results/'
pc.fname <- paste0('snprelate_exclude_', EXCLUDE, '_prune_r', LDTHRESH, '_w', WDW.mb)

getobj <- function(Rdat){
  obj <- load(Rdat)
  return(eval(parse(text = obj)))
}

mylib <- '/home/students/grindek/Rlib/'
library(gdsfmt, lib.loc = mylib)
library(tidyr, lib.loc = mylib)
library(dplyr, lib.loc = mylib)
library(RColorBrewer, lib.loc = mylib)
library(ggplot2, lib.loc = mylib)


## load PCcorr
pca.corr <- getobj(paste0(proj.dir, 'PC_geno_corr/', pc.fname, '.RData'))
corr.df <- data.frame(t(pca.corr$snpcorr))
n_pcs <- ncol(corr.df)
names(corr.df) <- paste0('PC', 1:n_pcs)


## load map info
gds <- openfn.gds('/projects/thornton/Lisa_Admixture_Mapping/geno/WHI_AA.gds')
chr <- read.gdsn(index.gdsn(gds, 'snp.chromosome'))
pos <- read.gdsn(index.gdsn(gds, 'snp.position'))
snpid <- read.gdsn(index.gdsn(gds, 'snp.id'))
if(all(snpid == pca.corr$snpid)){
  corr.df$chr <- as.factor(chr)
  corr.df$pos <- pos
} else{
  cat('SNPs in different orders. Need to fix.\n')
}
closefn.gds(gds)


## convert wide to long
corr <- corr.df %>%
        gather(PC, value, -chr, -pos) %>%
        filter(!is.na(value)) %>%
        mutate(value=abs(value)) %>%
        mutate(PC=factor(PC, levels=paste0("PC", 1:n_pcs)))


## set up colors
chr <- levels(corr$chr)
cmap <- setNames(rep_len(brewer.pal(8, "Dark2"), length(chr)), chr)


## plot over multiple pages
n_plots <- ceiling(n_pcs/as.integer(n_perpage))
bins <- as.integer(cut(1:n_pcs, n_plots))
for(i in 1:n_plots){
  bin <- paste0('PC', which(bins == i))
  dat <- filter(corr, PC %in% bin)
  
  p <- ggplot(dat, aes(chr, value, group = interaction(chr, pos), color = chr)) + 
	geom_point(position = position_dodge(0.8)) + 
	facet_wrap(~PC, scales = 'free', ncol = 1) + 
	scale_color_manual(values = cmap, breaks = names(cmap)) + 
	ylim(0,1) + 
	theme_classic(base_size = 18) + 
	theme(legend.position = 'none') + 
	#theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + 
	xlab('Chromosome') + 
	ylab('abs(Correlation)')
  ggsave(paste0(proj.dir, 'plots/PC_geno_corr/', pc.fname, '_', i, '.png'), plot = p, width = 10, height = 15)
}



