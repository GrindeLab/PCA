#### make Figure 1 ###

## packages
library(dplyr)
library(ggplot2)
library(gridExtra)

## set working directory
setwd("/Users/kgrinde/Documents/GitHub/PCA/manuscript/figs/barplots")

## read in WHI, JHS, and COPD plots
load('../WHI/barplots_WHI.RData')
load('../JHS/barplots_JHS.RData')
load('../COPD/barplots_COPD.RData')


p1 <- plotsWHI[[2]] + 
  labs(title = '(A) WHI SHARe', fill = 'Ancestral Population') +  
  theme(legend.key.size = unit(0.1, 'in'),
        legend.title = element_text(size=8),
        legend.text = element_text(size = 8),
        legend.position = 'bottom')
p2 <- plots[[1]] + 
  labs(title = '(B) JHS', fill = 'Ancestral Population') +  
  theme(legend.key.size = unit(0.1, 'in'),
        legend.title = element_text(size=8),
        legend.text = element_text(size = 8),
        legend.position = 'bottom')
p3 <- plotsCOPD[[1]] + 
  labs(title = '(C) COPDGene', fill = 'Ancestral Population') +  
  theme(legend.key.size = unit(0.1, 'in'),
        legend.title = element_text(size=8),
        legend.text = element_text(size = 8),
        legend.position = 'bottom')

pcombined <- grid.arrange(p1, p2, p3, nrow = 1)
ggsave(plot = pcombined, 'barplots.pdf', width = 8, height = 2.5, units = 'in', dpi = 'print')
