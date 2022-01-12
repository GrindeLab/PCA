## get data from pearson
## /projects/thornton/Lisa_Admixture_Mapping/results/global_anc/BINARY_WHI_AA_CEU_YRI_FINAL.2.Q

## load packages
library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)

## set working directory
setwd("/Users/kgrinde/Documents/GitHub/PCA/manuscript/figs/WHI")

## read in admixture proportions
propK2 <- read_table('BINARY_WHI_AA_CEU_YRI_FINAL.2.Q', col_names = F)

## add IDs
propK2 <- propK2 %>%
  mutate(ID = 1:nrow(propK2))

## check means
apply(propK2[1:2], 2, mean)

## update column names
## (looks like X1 = EUR and X2 = AFR)
names(propK2)[1:2] <- c('EUR', 'AFR')

## convert wide to long
propK2.long <- propK2 %>%
  pivot_longer(!ID, names_to = 'Pop', values_to = 'Prop')

## initial plots
first <- function(x) x[1]
last <- function(x) x[length(x)]

pWHI.2 <- propK2.long %>%
  mutate(ID = as.factor(ID)) %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first)) %>%
  mutate(Pop = forcats::fct_reorder(Pop, Prop, mean, .desc = FALSE)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('EUR' = 'darkorange2', 'AFR' = 'steelblue'))



#### average local ancestry ####
## get data from pearson
## /projects/thornton/Lisa_Admixture_Mapping/results/global_anc/global_ancestry.RData

load('global_ancestry.RData') ## global.anc

## make table of proportions
propLA <- data.frame(Pop1 = global.anc, 
                     Pop2 = 1 - global.anc, 
                     ID = 1:length(global.anc))

## check averages
apply(propLA[1:2], 2, mean) # Pop1 = Eur, Pop2 = Afr

## rename columns
names(propLA)[1:2] <- c('EUR', 'AFR')

## convert wide to long
propLA.long <- propLA %>%
  pivot_longer(!ID, names_to = 'Pop', values_to = 'Prop')

## make plot
pWHI.LA <- propLA.long %>%
  mutate(ID = as.factor(ID)) %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first)) %>%
  mutate(Pop = forcats::fct_reorder(Pop, Prop, mean, .desc = FALSE)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('EUR' = 'darkorange2', 'AFR' = 'steelblue'))

#### save plots ####
ggsave(plot = pWHI.2, 'barplot_supervised_K2_WHI.png')
ggsave(plot = pWHI.LA, 'barplot_avg_local_WHI.png')

plotsWHI <- list(pWHI.2, pWHI.LA)
save(plotsWHI, file = 'barplots_WHI.RData')
