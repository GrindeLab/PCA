## plot PC-genotype correlation in JHS and COPDGene

# load preliminary plots
load('../COPD/corr/plots/prune_FALSE_1_0_0.01_snprelate_corr_1.RData')
pcopd <- p + 
  ggtitle('(B) COPDGene')

load('../JHS/corr/plots/prune_FALSE_1_0_0.01_corr_1.RData')
pjhs <- p +
  ggtitle('(A) JHS')

library(gridExtra)
pcombo <- grid.arrange(pjhs, pcopd, nrow = 1)
ggsave('topmed_corr.png', plot = pcombo, width=20, height=15)
