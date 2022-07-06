#### set up ####
library(ggplot2)
library(dplyr)
library(RColorBrewer)
library(gridExtra)
library(cowplot)
#setwd('P:/Documents/Research/Dissertation/Admixture Mapping/Simulation Results/Spurious Associations/gwas/')
setwd("/Users/kgrinde/Documents/GitHub/PCA/manuscript/figs/spurious_counts/gwas")

#### updates for manuscript ####
## focus on: 
## low_low (causal SNP not correlated with PCs, small ancestral allele freq diff) --- don't worry about confounding or collider here
## low_high (causal SNP not correlated with PCs, large ancestral allele freq diff) --- worry about confounding but not collider
## high_none (causal SNP has high SNP loading for naive PCs 2, 3, and/or 4) --- colider bias if you adjust for 4 PCs without pruning! (with or without exclusions)
## peak_none (causal SNP has highest SNP loading for naive PCs 2, 3, and/or 4) --- problems even worse if SNP is more correlated with PC
##
## lower panel: plots with all values of beta
## upper panel: plots (barplots) just focusing on beta = 1 (or this could be a table?)
##
## main discussion points:
## impact of ancestral allele freq diff
## impact of correlation with PC
## impact of effect size of causal SNP


#### Make Plots with All Betas ####
### create plot for given table of results
make_plot <- function(type){
  ## read file
  fname <- paste0('average_counts_',type,'.csv')
  amap <- read.csv(fname)
  amap <- amap %>%
    mutate(`LD-based exclusions` = recode(exclusions, none = 'None', lit = 'Regions with high/extended LD'),
           `LD pruning` = recode(pruning, none = 'None', `0.1` = 'r^2 < 0.1, window = 0.5 Mb'),
           `Adjustment technique` = recode(pcs, pi = 'Model-based admixture prop.', `1` = '1 PC', `4` = '4 PCs', none = 'None'))
  
  amap$covariates <- with(amap,paste(pcs,exclusions,pruning,sep='_'))
  amap$covariates[1] <- 'pi'
  amap$covariates[10] <- 'none'
  ## wide to long
  amap.long <- reshape(amap,idvar='covariates', ids = amap$covariates,
                       times = names(amap)[1:7], timevar='beta',
                       varying = list(names(amap)[1:7]), direction = 'long')
  amap.long$beta <- as.numeric(substr(amap.long$beta,2,5))
  names(amap.long)[9] <- 'spur'
  ## plot
  p <- ggplot(data=amap.long,aes(x=beta,y=spur))+
    geom_line(aes(group=covariates,color=`Adjustment technique`,linetype=`LD pruning`),size=1, alpha = 0.7)+
    geom_point(aes(color=`Adjustment technique`,shape=`LD-based exclusions`),size=2)+
    coord_cartesian(ylim=c(0,2))+
    ylab('Average spurious associations')+
    xlab(expression(paste('Effect size of causal variant (', beta, ')')))+
    theme_bw()+
    #geom_hline(yintercept=0.05,linetype=3)+
    ggtitle(type) +
    guides(color = guide_legend(order = 1), shape = guide_legend(order = 2), linetype = guide_legend(order = 3)) + 
    scale_color_brewer(palette = 'Dark2')
  return(p)
}

### make plots for each type of setting
all_sims <- make_plot('all') + ggtitle('(A) All simulation settings') + theme(legend.position = 'none')
peak_none <- make_plot('peak_none') + ggtitle('(E) Highest loading') + theme(legend.position = 'none')
peak_lit <- make_plot('peak_lit')
peak_both <- make_plot('peak_both')
high_none <- make_plot('high_none') + ggtitle('(D) High loading') + theme(legend.position = 'none')
high_lit <- make_plot('high_lit')
high_both <- make_plot('high_both')
low_high <- make_plot('low_high') + ggtitle('(C) Low loading') + theme(legend.position = 'none')
low_low <- make_plot('low_low') + ggtitle('(B) Small diff. in ancestral allele freq.') + theme(legend.position = 'none')

## get legend by itself
lgnd <- get_legend(peak_lit)

ggdraw(plot_grid(plot_grid(all_sims, low_high, ncol = 1, align = 'v'),
                 plot_grid(low_low, high_none, ncol = 1, align = 'v'),
                 plot_grid(lgnd, peak_none, ncol = 1, align = 'v'),
                 nrow = 1,
                 rel_widths = c(1, 1, 1)))
ggsave(filename = 'spurious_allbeta.pdf', dpi = 'print', width = 10, height = 7, units = 'in')

#ggdraw(plot_grid(plot_grid(low_low, high_none, ncol = 1, align = 'v'),
#                 plot_grid(low_high, peak_none, ncol = 1, align = 'v'),
#                 plot_grid(lgnd, NULL, ncol = 1, align = 'v'),
#                 nrow = 1,
#                 rel_widths = c(1, 1, 0.6)))
#ggsave(filename = 'old_spurious_allbeta.pdf', dpi = 'print', width = 10, height = 7, units = 'in')



#### Make Plots with Beta = 1 ####
make_barplot <- function(type){
  ## read file
  fname <- paste0('average_counts_',type,'.csv')
  amap <- read.csv(fname)
  amap <- amap %>%
    mutate(`LD-based exclusions` = recode(exclusions, none = 'No exclusions', lit = 'Exclude high LD regions'),
           `LD pruning` = recode(pruning, none = 'No LD pruning', `0.1` = 'LD pruning (r^2 < 0.1, window = 0.5 Mb)'),
           `Adjustment technique` = recode(pcs, pi = 'Model-based admixture prop.', `1` = '1 PC', `4` = '4 PCs', none = 'None'))
  
  amap$covariates <- with(amap,paste(pcs,exclusions,pruning,sep='_'))
  amap$covariates[1] <- 'pi'
  amap$covariates[10] <- 'none'
  ## wide to long
  amap.long <- reshape(amap,idvar='covariates', ids = amap$covariates,
                       times = names(amap)[1:7], timevar='beta',
                       varying = list(names(amap)[1:7]), direction = 'long')
  amap.long$beta <- as.numeric(substr(amap.long$beta,2,5))
  names(amap.long)[9] <- 'spur'
  ## just keep beta = 1
  amap.beta1 <- amap.long %>%
    filter(beta == 1)
  ## add pre-processing column
  amap.beta1 <- amap.beta1 %>%
    mutate(preprocess = paste(`LD-based exclusions`, `LD pruning`, sep = '\n'))
  amap.beta1 <- amap.beta1 %>%
    mutate(preprocess = recode(preprocess, `Exclude high LD regions\nLD pruning (r^2 < 0.1, window = 0.5 Mb)` = 'Both',
                               `Exclude high LD regions\nNo LD pruning` = 'Exclusions,\nNo Pruning',
                               `No exclusions\nLD pruning (r^2 < 0.1, window = 0.5 Mb)` = 'Pruning,\nNo Exclusions',
                               `No exclusions\nNo LD pruning`  = 'Neither')) %>%
    mutate(preprocess = factor(preprocess, levels = c('Neither', 'Exclusions,\nNo Pruning', 'Pruning,\nNo Exclusions', 'Both')))
  ## remove the 'none' results
  amap.beta1 <- amap.beta1 %>%
    filter(covariates != 'none')
  ## just keep 1 PC (no prune or exclusion), 1 PC (prune + exclude), 4 PC (neither), 4 PC (both), admix prop
  #amap.beta1 <- amap.beta1 %>%
  #  filter(covariates %in% c('pi', '1_none_none', '1_lit_0.1', '4_none_none', '4_lit_0.1'))
  ## plot
  p <- amap.beta1 %>%
    #mutate(LD = paste(exclusions, pruning, sep = '_')) %>%
    #mutate(LD = recode(LD, `none_none` = 'no exclusions or pruning',
    #                   `lit_0.1` = 'exclusions and pruning \n(r^2 < 0.1, 0.5 Mb window)')) %>%
    ##ggplot(aes(x = LD , y = spur)) +
    ggplot(aes(x = `Adjustment technique`, y = spur)) + 
    geom_col(aes(fill = `Adjustment technique`)) + 
    scale_fill_brewer(palette = 'Dark2') + 
    ##facet_grid(. ~ `Adjustment technique`, scales = 'free_x', space = 'free_x') + 
    #facet_grid(. ~ LD, scales = 'free_x', space = 'free_x') + 
    facet_grid(. ~ preprocess, scales = 'free_x', space = 'free_x') + 
    #facet_grid( `LD pruning` ~ `LD-based exclusions`, scales = 'free_x', space = 'free_x') + 
    theme_bw()+
    geom_hline(yintercept=0.05,linetype=3)+
    coord_cartesian(ylim=c(0,0.31))+
    ylab('Average spurious associations') + 
    xlab('') + 
    theme(axis.text.x = element_blank())+
    ggtitle(type)
  return(p)
}

bar_all <- make_barplot('all') + ggtitle('(A) All simulation settings') + theme(legend.position = 'none')
bar_peak_none <- make_barplot('peak_none') + ggtitle('(E) Highest loading') + theme(legend.position = 'none')
bar_peak_lit <- make_barplot('peak_lit')
bar_peak_both <- make_barplot('peak_both')
bar_high_none <- make_barplot('high_none') + ggtitle('(D) High loading') + theme(legend.position = 'none')
bar_high_lit <- make_barplot('high_lit')
bar_high_both <- make_barplot('high_both')
bar_low_high <- make_barplot('low_high') + ggtitle('(C) Low loading') + theme(legend.position = 'none')
bar_low_low <- make_barplot('low_low') + ggtitle('(B) Small diff. in ancestral allele frequencies') + theme(legend.position = 'none')

bar_lgnd <- get_legend(bar_peak_lit)

#grid.arrange(bar_low_high, bar_high_none, bar_peak_none, nrow = 1)

#ggdraw(plot_grid(plot_grid(bar_low_low, bar_high_none, ncol = 1, align = 'v'),
#                 plot_grid(bar_low_high, bar_peak_none, ncol = 1, align = 'v'),
#                 plot_grid(bar_lgnd, NULL, ncol = 1, align = 'v'),
#                 nrow = 1,
#                 rel_widths = c(1, 1, 0.5)))
#ggsave(filename = 'spurious_beta1.pdf', dpi = 'print', width = 11, height = 6, units = 'in')

ggdraw(plot_grid(plot_grid(bar_all, bar_low_high, ncol = 1, align = 'v'),
                 plot_grid(bar_low_low, bar_high_none, ncol = 1, align = 'v'),
                 plot_grid(bar_lgnd, bar_peak_none, ncol = 1, align = 'v'),
                 nrow = 1,
                 rel_widths = c(1, 1, 1)))
ggsave(filename = 'figure7_spurious_beta1.pdf', dpi = 'print', width = 13.5, height = 6, units = 'in')


#### Combine into one figure ####
make_barplot2 <- function(type){
  ## read file
  fname <- paste0('average_counts_',type,'.csv')
  amap <- read.csv(fname)
  amap <- amap %>%
    mutate(`LD-based exclusions` = recode(exclusions, none = 'None', lit = 'Regions with high/extended LD'),
           `LD pruning` = recode(pruning, none = 'None', `0.1` = 'r^2 < 0.1, window = 0.5 Mb'),
           `Adjustment technique` = recode(pcs, pi = 'Model-based admixture prop.', `1` = '1 PC', `4` = '4 PCs', none = 'None'))
  amap$covariates <- with(amap,paste(pcs,exclusions,pruning,sep='_'))
  amap$covariates[1] <- 'pi'
  amap$covariates[10] <- 'none'
  ## wide to long
  amap.long <- reshape(amap,idvar='covariates', ids = amap$covariates,
                       times = names(amap)[1:7], timevar='beta',
                       varying = list(names(amap)[1:7]), direction = 'long')
  amap.long$beta <- as.numeric(substr(amap.long$beta,2,5))
  names(amap.long)[9] <- 'spur'
  ## just keep beta = 1
  amap.beta1 <- amap.long %>%
    filter(beta == 1)
  ## just keep 1 PC (no prune or exclusion), 1 PC (prune + exclude), 4 PC (neither), 4 PC (both), admix prop
  amap.beta1 <- amap.beta1 %>%
    filter(covariates %in% c('pi', '1_none_none', '1_lit_0.1', '4_none_none', '4_lit_0.1'))
  ## plot
  p <- amap.beta1 %>%
    mutate(LD = paste(exclusions, pruning, sep = '_')) %>%
    mutate(LD = recode(LD, `none_none` = 'No Exclusions \nor Pruning',
                       `lit_0.1` = 'Exclude \nand Prune')) %>%
    #ggplot(aes(x = LD , y = spur)) +
    ggplot(aes(x = covariates, y = spur)) + 
    geom_col(aes(fill = `Adjustment technique`)) + 
    scale_fill_brewer(palette = 'Dark2') + 
    #facet_grid(. ~ `Adjustment technique`, scales = 'free_x', space = 'free_x') + 
    facet_grid(. ~ LD, scales = 'free_x', space = 'free_x') + 
    theme_bw()+
    geom_hline(yintercept=0.05,linetype=3)+
    coord_cartesian(ylim=c(0,0.35))+
    ylab('Average spurious associations') + 
    xlab('') + 
    theme(axis.text.x = element_blank())+
    ggtitle(type)
  return(p)
}

bar_all2 <- make_barplot2('all')
bar_peak_none2 <- make_barplot2('peak_none') + ggtitle('Highest loading') + theme(legend.position = 'none')
bar_high_none2 <- make_barplot2('high_none') + ggtitle('High loading') + theme(legend.position = 'none')
bar_low_high2 <- make_barplot2('low_high') + ggtitle('Low loading, large freq. diff.') + theme(legend.position = 'none')
bar_low_low2 <- make_barplot2('low_low') + ggtitle('Low loading, small freq. diff.') + theme(legend.position = 'none')
bar_lgnd2 <- get_legend(bar_all2)

low_high2 <- make_plot('low_high') + ggtitle('Low loading, large freq. diff.') + theme(legend.position = 'none')
low_low2 <- make_plot('low_low') + ggtitle('Low loading, small freq. diff.') + theme(legend.position = 'none')


ggdraw(plot_grid(plot_grid(bar_low_low2, bar_low_high2, bar_high_none2, bar_peak_none2, 
                           bar_lgnd2, nrow = 1, rel_widths = c(1,1,1,1,0.8)),
                 plot_grid(low_low2, low_high2, high_none, peak_none, lgnd, 
                           nrow = 1, rel_widths = c(1,1,1,1,0.8)),
                 ncol = 1))
ggsave(filename = 'spurious_sims.pdf', dpi = 'print', width = 14, height = 7, units = 'in')
