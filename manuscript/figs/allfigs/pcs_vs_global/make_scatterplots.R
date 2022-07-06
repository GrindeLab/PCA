#### make Figure 2 ####

## packages
library(readr)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(tidyr)

## set working directory
setwd("/Users/kgrinde/Documents/GitHub/PCA/manuscript/figs/pcs_vs_global")

## useful functions
get_obj <- function(rdat){
  rdat.name <- load(rdat)
  obj <- eval(parse(text = rdat.name))
  return(obj)
}

#### WHI ####
#/projects/thornton/Lisa_Admixture_Mapping/results/covariates/covar_pi.txt
whi.global <- read_table('../WHI/covar_pi.txt', col_names = F)
whi.global %>% summarize(mean(X3)) # looks like this is European proportion
names(whi.global) <- c('ID1', 'ID2', 'EUR')
whi.global <- whi.global %>%
  mutate(AFR = 1 - EUR)

#/projects/thornton/Lisa_Admixture_Mapping/results/covariates/pcs_4/pca_snprelate_exclude_none_prune_1_0.5.txt
whi.naive.pcs <- read_table('../WHI/pca_snprelate_exclude_none_prune_1_0.5.txt', col_names = F)
names(whi.naive.pcs) <- c('ID1', 'ID2', 'PC1', 'PC2', 'PC3', 'PC4')

# combine into single df
whi.all <- whi.global %>%
  left_join(whi.naive.pcs)

# wide to long
whi.all.long <- whi.all %>%
  pivot_longer(PC1:PC4, names_to = "PC", values_to = "value")

# plot
p.WHI <- whi.all.long %>%
  ggplot(aes(x = AFR, y = value)) + 
  geom_point() + 
  facet_grid(. ~ PC) +
  theme_bw() + 
  labs(x = 'African Admixture Proportion', y = 'PC Score', title = '(A) WHI SHARe')


#### JHS ####
#/projects/browning/brwnlab/kelsey/spurious_assoc/jhs/admixture/jhs.2.Q_withID.txt
jhs.global <- read_table('../JHS/jhs.2.Q_withID.txt', col_names = F)
jhs.global %>% summarize(mean(X1), mean(X2)) # looks like this is EUR then AFR
names(jhs.global) <- c('EUR', 'AFR', 'ID')

#/projects/browning/brwnlab/kelsey/spurious_assoc/jhs/pcs/snprelate_excludeFALSE_rsq1_win0_maf0.01.RData
jhs.pcs <- get_obj('../JHS/snprelate_excludeFALSE_rsq1_win0_maf0.01.RData')
jhs.pcs.df <- data.frame(ID = jhs.pcs$sample.id, 
                         PC1 = jhs.pcs$eigenvect[,1], 
                         PC2 = jhs.pcs$eigenvect[,2],
                         PC3 = jhs.pcs$eigenvect[,3],
                         PC4 = jhs.pcs$eigenvect[,4], 
                         stringsAsFactors = F)

# merge into one
jhs.all <- jhs.global %>%
  left_join(jhs.pcs.df)

# filter out Europeans
#/projects/browning/brwnlab/kelsey/spurious_assoc/jhs/admixture/eur_ids.RData
eur.ids <- get_obj('../JHS/eur_ids.RData')
jhs.all.filtered <- jhs.all %>%
  filter(!(ID %in% eur.ids))

# wide to long
jhs.all.long <- jhs.all.filtered %>%
  pivot_longer(PC1:PC4, names_to = "PC", values_to = "value")

# plot
p.JHS <- jhs.all.long %>%
  ggplot(aes(x = AFR, y = value)) + 
  geom_point() + 
  facet_grid(. ~ PC) +
  theme_bw() + 
  labs(x = 'African Admixture Proportion', y = 'PC Score', title = '(B) JHS')


#### COPD ####
#/projects/browning/brwnlab/kelsey/spurious_assoc/copd/admixture_proportions/K2.txt
copd.global <- read_table('../COPD/K2.txt', col_names = F)
copd.global %>% summarize_all(mean) # EUR (lots of EA in this sample) then AFR
names(copd.global) <- c('EUR', 'AFR', 'ID')

#/projects/browning/brwnlab/kelsey/spurious_assoc/copd/pcs/snprelate_excludeFALSE_rsq1_win0_maf0.01.RData
copd.pcs <- get_obj('../COPD/snprelate_excludeFALSE_rsq1_win0_maf0.01.RData')
copd.pcs.df <- data.frame(ID = copd.pcs$sample.id, 
                         PC1 = copd.pcs$eigenvect[,1], 
                         PC2 = copd.pcs$eigenvect[,2],
                         PC3 = copd.pcs$eigenvect[,3],
                         PC4 = copd.pcs$eigenvect[,4], 
                         stringsAsFactors = F)

# merge into one
copd.all <- copd.global %>%
  left_join(copd.pcs.df)

# remove Europeans
copd.all.filtered <- copd.all %>%
  filter(EUR <= 0.7)

# wide to long
copd.all.long <- copd.all.filtered %>%
  pivot_longer(PC1:PC4, names_to = "PC", values_to = "value")

# plot
p.COPD <- copd.all.long %>%
  ggplot(aes(x = AFR, y = value)) + 
  geom_point() + 
  facet_grid(. ~ PC) +
  theme_bw() + 
  labs(x = 'African Admixture Proportion', y = 'PC Score', title = '(C) COPDGene')


#### Combine into one figure ####
pcombined <- grid.arrange(p.WHI, p.JHS, p.COPD, nrow = 3)
ggsave(plot = pcombined, 'pcs_vs_global.pdf', width = 7, height = 7, units = 'in', dpi = 'print')
