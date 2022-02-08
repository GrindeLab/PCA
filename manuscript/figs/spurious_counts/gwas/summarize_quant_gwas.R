### set up
library(ggplot2)
#setwd('P:/Documents/Research/Dissertation/Admixture Mapping/Simulation Results/Spurious Associations/gwas/')
setwd("/Users/kgrinde/Documents/GitHub/PCA/manuscript/figs/spurious_counts/gwas")

### create plot for given table of results
make_plot <- function(type){
  ## read file
  fname <- paste0('average_counts_',type,'.csv')
  amap <- read.csv(fname)
  amap$covariates <- with(amap,paste(pcs,exclusions,pruning,sep='_'))
  amap$covariates[1] <- 'pi'
  amap$covariates[10] <- 'none'
  ## wide to long
  amap.long <- reshape(amap,idvar='covariates', ids = amap$covariates,
                       times = names(amap)[1:7], timevar='beta',
                       varying = list(names(amap)[1:7]), direction = 'long')
  amap.long$beta <- as.numeric(substr(amap.long$beta,2,5))
  names(amap.long)[6] <- 'spur'
  ## plot
  p <- ggplot(data=amap.long,aes(x=beta,y=spur))+
    geom_line(aes(group=covariates,color=pcs,linetype=exclusions),size=1)+
    geom_point(aes(color=pcs,shape=pruning),size=2)+
    coord_cartesian(ylim=c(0,3))+
    ylab('Average # of spurious associations')+
    xlab('Beta')+
    theme_bw()+
    geom_hline(yintercept=0.05,linetype=3)+
    ggtitle(type)
  return(p)
}

### make plots for each type of setting
all <- make_plot('all')
peak_none <- make_plot('peak_none')
peak_lit <- make_plot('peak_lit')
peak_both <- make_plot('peak_both')
high_none <- make_plot('high_none')
high_lit <- make_plot('high_lit')
high_both <- make_plot('high_both')
low_high <- make_plot('low_high')
low_low <- make_plot('low_low')


### arrange plots
library('gridExtra')
#jpeg('test.jpg',width=800,height=800)
grid.arrange(all,low_low,low_high,high_none,high_lit,high_both,
             peak_none,peak_lit,peak_both,
             nrow=3,ncol=3)
#dev.off()



### updates for manuscript
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