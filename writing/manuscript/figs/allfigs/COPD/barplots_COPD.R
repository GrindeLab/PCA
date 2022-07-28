## get data from pearson
## /projects/browning/brwnlab/kelsey/spurious_assoc/copd/admixture_proportions/K{2,3,4}.txt

## load packages
library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)

## set working directory
setwd("/Users/kgrinde/Documents/GitHub/PCA/manuscript/figs/COPD")

## read in admixture proportions
propK2 <- read_table('K2.txt', col_names = F)
propK3 <- read_table('K3.txt', col_names = F)
propK4 <- read_table('K4.txt', col_names = F)

## add column names
names(propK2) <- c(paste0('Pop', 1:2), 'ID')
names(propK3) <- c(paste0('Pop', 1:3), 'ID')
names(propK4) <- c(paste0('Pop', 1:4), 'ID')

## check if IDs are in same order
all(propK2$ID == propK3$ID)
all(propK2$ID == propK4$ID)

## compare proportions
cor(propK2[1:2], propK3[1:3]) 
  # K2 Pop 2 ~=~ K3 Pop 2
cor(propK2[1:2], propK4[1:4]) 
  # K2 Pop 2 ~=~ K4 Pop 3
cor(propK3[1:3], propK4[1:4]) 
  # K3 Pop 2 ~=~ K4 Pop 3
  # K3 Pop 3 ~=~ K4 Pop 4
  # K3 Pop 1 ~=~ K4 Pop 2

apply(propK2[1:2], 2, mean)
apply(propK3[1:3], 2, mean)
apply(propK4[1:4], 2, mean)

## update column names and order
names(propK2) <- c('Pop2', 'Pop1', 'ID')
names(propK3) <- c('Pop3', 'Pop1', 'Pop2', 'ID')
names(propK4) <- c('Pop4', 'Pop3', 'Pop1', 'Pop2', 'ID')

propK2 <- propK2 %>%
  select(Pop1, Pop2, ID)
propK3 <- propK3 %>%
  select(Pop1, Pop2, Pop3, ID)
propK4 <- propK4 %>%
  select(Pop1, Pop2, Pop3, Pop4, ID)

## convert wide to long
propK2.long <- propK2 %>%
  pivot_longer(!ID, names_to = 'Pop', values_to = 'Prop')
propK3.long <- propK3 %>%
  pivot_longer(!ID, names_to = 'Pop', values_to = 'Prop')
propK4.long <- propK4 %>%
  pivot_longer(!ID, names_to = 'Pop', values_to = 'Prop')

## initial plots
first <- function(x) x[1]

propK2.long %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'darkorange2', 'Pop2' = 'steelblue'))

propK3.long %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'darkorange2', 'Pop2' = 'steelblue4', 'Pop3' = 'steelblue1'))

propK4.long %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'darkorange2', 'Pop2' = 'steelblue4', 'Pop3' = 'steelblue', 'Pop4' = 'steelblue1'))


#### remove Europeans from plots ####
# use 30% cutoff from Parker et al. 2014 "Admixture mapping identifies a quantitative trait locus associated with..."
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4190160/
cutoff <- 0.29

## find IDs with African prop > 0.9999
afr.ids.K2 <- propK2 %>%
  filter(Pop1 >= cutoff) %>%
  pull(ID)
afr.ids.K3 <- propK3 %>%
  filter(Pop1 >= cutoff) %>%
  pull(ID)
afr.ids.K4 <- propK4 %>%
  filter(Pop1 >= cutoff) %>%
  pull(ID)
afr.ids.combined <- unique(c(afr.ids.K2, afr.ids.K3, afr.ids.K4))

## now, filter out Europeans
propK2.long.filtered <- propK2.long %>%
  filter(ID %in% afr.ids.combined)
propK3.long.filtered <- propK3.long %>%
  filter(ID %in% afr.ids.combined)
propK4.long.filtered <- propK4.long %>%
  filter(ID %in% afr.ids.combined)

## check average proportions after filtering
propK2.long.filtered %>%
  group_by(Pop) %>%
  summarize(mean(Prop))
propK3.long.filtered %>%
  group_by(Pop) %>%
  summarize(mean(Prop))
propK4.long.filtered %>%
  group_by(Pop) %>%
  summarize(mean(Prop))

## plot after filtering
## Orange = EUR = Pop1, Blue = AFR = Pop2
pCOPD.2 <- propK2.long.filtered %>%
  mutate(Pop = ifelse(Pop == 'Pop1', 'Pop2', 'Pop1')) %>% # flip labels to match JHS
  mutate(ID = forcats::fct_reorder(ID, Prop, first, .desc = TRUE)) %>%
  mutate(Pop = forcats::fct_reorder(Pop, Prop, mean)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'darkorange2', 'Pop2' = 'steelblue'))

pCOPD.3 <- propK3.long.filtered %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first, .desc = TRUE)) %>%
  mutate(Pop = forcats::fct_reorder(Pop, Prop, mean)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'steelblue', 'Pop2' = 'darkorange2', 'Pop3' = 'orange'))

pCOPD.4 <- propK4.long.filtered %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first, .desc = TRUE)) %>%
  mutate(Pop = forcats::fct_reorder(Pop, Prop, mean)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'steelblue', 'Pop2' = 'darkorange2', 'Pop3' = 'orange', 'Pop4' = 'darkorange4'))

## save plots
ggsave(plot = pCOPD.2, 'barplot_unsupervised_K2_COPD.png')
ggsave(plot = pCOPD.3, 'barplot_unsupervised_K3_COPD.png')
ggsave(plot = pCOPD.4, 'barplot_unsupervised_K4_COPD.png')

plotsCOPD <- list(pCOPD.2, pCOPD.3, pCOPD.4)
save(plotsCOPD, file = 'barplots_COPD.RData')
