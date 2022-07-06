amap <- read.csv('../Desktop/Book1.csv')
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
library(ggplot2)
ggplot(data=amap.long,aes(x=beta,y=spur))+
  geom_line(aes(group=covariates,color=pcs,linetype=exclusions),size=1)+
  geom_point(aes(color=pcs,shape=pruning),size=2)+
  coord_cartesian(ylim=c(0,2))+
  ylab('Average # of spurious associations')+
  xlab('Beta')+
  theme_bw()+
  geom_hline(yintercept=0.05,linetype=3)+
  ggtitle('Admixture Mapping Results')


### Gwas results ####
gwas <- read.csv('../Desktop/Book2.csv')
gwas$covariates <- with(gwas,paste(pcs,exclusions,pruning,sep='_'))
gwas$covariates[1] <- 'pi'
gwas$covariates[10] <- 'none'

## wide to long
gwas.long <- reshape(gwas,idvar='covariates', ids = gwas$covariates,
                     times = names(gwas)[1:7], timevar='beta',
                     varying = list(names(gwas)[1:7]), direction = 'long')
gwas.long$beta <- as.numeric(substr(gwas.long$beta,2,5))
names(gwas.long)[6] <- 'spur'

## plot
ggplot(data=gwas.long,aes(x=beta,y=spur))+
  geom_line(aes(group=covariates,color=pcs,linetype=exclusions),size=1)+
  geom_point(aes(color=pcs,shape=pruning),size=2)+
  coord_cartesian(ylim=c(0,1))+
  ylab('Average # of spurious associations')+
  xlab('Beta')+
  theme_bw()+
  geom_hline(yintercept=0.05,linetype=3)+
  ggtitle('GWAS Results')
