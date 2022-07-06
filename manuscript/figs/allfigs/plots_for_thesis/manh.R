args <- commandArgs(TRUE)
rep <- as.numeric(args[[1]]) # 60
type <- args[[2]] # amap, gwas
beta <- 1

## directory info
projdir <- '/projects/thornton/Lisa_Admixture_Mapping/'
resdir <- paste0(projdir, 'linear_regression/results/')
plotdir <- paste0(projdir, 'results/plots/for_thesis/')


## packages
library(ggplot2)
library(RColorBrewer)
library(tidyr)
library(dplyr)

## set signif threshold
if(type == 'gwas'){
  signif <- 5e-08
} else{
  signif <- 2e-5
}

## load and plot results
plots <- list()
#covars <- c('none', 'pi', 'pcs_1_none_1_0.5', 'pcs_1_lit_0.1_0.5', 'pcs_4_none_1_0.5', 'pcs_4_lit_0.1_0.5')
covars <- c('none', 'pcs_1_none_1_0.5', 'pcs_4_none_1_0.5', 'pi', 'pcs_1_lit_0.1_0.5', 'pcs_4_lit_0.1_0.5')
for(i in 1:6){
  res <- read.table(paste0(resdir, type, '_spur_', covars[i], '_beta1_snp', rep, '.assoc.linear'), header = T)
  res <- subset(res, TEST == 'ADD')

  res <- res %>%
	mutate(chr = factor(CHR)) %>%
	mutate(logp = -log10(P))
	
  chr <- levels(res$chr)
  cmap <- setNames(rep_len(brewer.pal(8, "Dark2"), length(chr)), chr)

  plots[[i]] <- ggplot(res, aes(chr, logp, group = interaction(chr, BP), color = chr)) +
	geom_point(position = position_dodge(0.8)) +
	scale_color_manual(values = cmap, breaks = names(cmap)) +
	geom_hline(yintercept = -log10(signif), linetype = 'dashed') +
	theme_bw() + 
	theme(legend.position = 'none') +
	xlab('Chromosome') +
	ylab(expression(-log[10](p))) +
	theme(text = element_text(size = 20)) +
	coord_cartesian(ylim=c(0,12)) +
	ggtitle(paste0('(', c('A', 'B', 'C', 'D', 'E', 'F')[i], ')'))
  ggsave(file = paste0(plotdir, 'manh_', type, '_', rep, '_', covars[i], '.png'), plot = plots[[i]], width = 10, height = 5)
}

## combine all plots
library(gridExtra)
plot.all <- grid.arrange(grobs = plots, nrow = 2)
ggsave(file = paste0(plotdir, 'manh_', type, '_', rep, '.png'), plot = plot.all, width = 20, height = 10) 

