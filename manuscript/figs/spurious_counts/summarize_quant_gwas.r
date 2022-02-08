### set up
library(ggplot2)
setwd('P:/Documents/Research/Dissertation/Admixture Mapping/Simulation Results/Spurious Associations/gwas/')

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
    coord_cartesian(ylim=c(0,1.5))+
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
jpeg('test.jpg',width=800,height=800)
grid.arrange(all,low_low,low_high,high_none,high_lit,high_both,
             peak_none,peak_lit,peak_both,
             nrow=3,ncol=3)
dev.off()
