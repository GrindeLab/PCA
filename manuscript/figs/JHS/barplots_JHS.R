## get data from pearson
## /projects/browning/brwnlab/kelsey/spurious_assoc/jhs/admixture/jhs.{2,3}.Q_withID.txt

## load packages
library(readr)
library(dplyr)
library(ggplot2)
library(tidyr)

## set working directory
setwd("/Users/kgrinde/Documents/GitHub/PCA/manuscript/figs/JHS")

## read in admixture proportions
propK2 <- read_table('jhs.2.Q_withID.txt', col_names = F)
propK3 <- read_table('jhs.3.Q_withID.txt', col_names = F)

## add column names
names(propK2) <- c(paste0('Pop', 1:2), 'ID')
names(propK3) <- c(paste0('Pop', 1:3), 'ID')

## check if IDs are in same order
all(propK2$ID == propK3$ID)

## compare proportions
cor(propK2[1:2], propK3[1:3]) 
  # K2 Pop 1 ~=~ K3 Pop 3
  # so we'll rename K3 Pops to 2, 3, 1
names(propK3) <- c('Pop2', 'Pop3', 'Pop1', 'ID')

## convert wide to long
propK2.long <- propK2 %>%
  pivot_longer(!ID, names_to = 'Pop', values_to = 'Prop')
propK3.long <- propK3 %>%
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


last <- function(x) x[length(x)]

propK3.long %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, last)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'darkorange2', 'Pop2' = 'steelblue4', 'Pop3' = 'steelblue1'))

#### remove Europeans from plots ####
## first, figure out which Pop is European
## (looks like Pop1)
propK2.long %>%
  group_by(Pop) %>%
  summarize(mean(Prop))
propK3.long %>%
  group_by(Pop) %>%
  summarize(mean(Prop))

## find IDs with European prop > 0.9999
eur.ids.K2 <- propK2 %>%
  filter(Pop1 > 0.9999) %>%
  pull(ID)
eur.ids.K3 <- propK3 %>%
  filter(Pop1 > 0.9999) %>%
  pull(ID)
eur.ids.combined <- unique(c(eur.ids.K2, eur.ids.K3))

## now, filter out Europeans
propK2.long.filtered <- propK2.long %>%
  filter(!(ID %in% eur.ids.combined))
propK3.long.filtered <- propK3.long %>%
  filter(!(ID %in% eur.ids.combined))

## plot after filtering
pJHS.2 <- propK2.long.filtered %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, first)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'darkorange2', 'Pop2' = 'steelblue'))
pJHS.3 <- propK3.long.filtered %>%
  mutate(ID = forcats::fct_reorder(ID, Prop, last)) %>%
  ggplot(aes(x = ID, y = Prop, fill = Pop)) +
  geom_col(width = 1) + 
  labs(fill = 'Ancestral\nPopulation', y = 'Admixture Proportion') +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c('Pop1' = 'darkorange2', 'Pop2' = 'steelblue4', 'Pop3' = 'steelblue1'))

## save plots
ggsave(plot = pJHS.2, 'barplot_unsupervised_K2_JHS.png')
ggsave(plot = pJHS.3, 'barplot_unsupervised_K3_JHS.png')

plots <- list(pJHS.2, pJHS.3)
save(plots, file = 'barplots_JHS.RData')
