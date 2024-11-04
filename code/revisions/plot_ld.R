library(R.utils)
library(tidyverse)

#gunzip( "/Users/kgrinde/Desktop/ld_jhs_chr8.ld.gz")
ld <- read.table("/Users/kgrinde/Desktop/ld_jhs_chr8.ld", header = T)
head(ld)


# attempt at heatmap 
# NOT GOING WELL
# snpsA <- ld %>%
#   mutate(SNP_A = as.factor(SNP_A)) %>%
#   pull(SNP_A) %>%
#   levels()
# snpsB <- ld %>%
#   mutate(SNP_B = as.factor(SNP_B)) %>%
#   pull(SNP_B) %>%
#   levels()
# 
# set.seed(1)
# sel.snps <- sample(intersect(snpsA,snpsB), size = 10, replace = F)
#
# ld %>%
#   filter(SNP_A %in% sel.snps | SNP_B %in% sel.snps) %>%
#   ggplot(aes(x = as.factor(BP_A), y = as.factor(BP_B), fill = R2)) + 
#   geom_tile(color = "white") + 
#   scale_fill_gradient2(
#     low = "blue", high = "red", mid = "white", 
#     midpoint = 0, limit = c(-1,1)) +
#   labs(x = "", y = "") +
#   theme_minimal() + 
#   theme(axis.text.x = element_text(angle = 60, hjust = 1)) + 
#   coord_fixed()

# try plotting LD decay
ld <- ld %>%
  mutate(dist_BP = abs(BP_A - BP_B))

set.seed(1)
ld %>%
  sample_n(size = 100000, replace = F) %>%
  ggplot(aes(x = dist_BP, y = R2)) + 
  geom_point(alpha = 0.2) + 
  geom_smooth(se = F) + 
  labs(y = expression(r^2), x = 'Distance (bp)') + 
  theme_classic()

# plot average LD for each SNP 
avgLD <- ld %>%
  group_by(SNP_A) %>%
  summarize(avgLD = mean(R2))

map <- ld %>%
  select(SNP_A, BP_A) %>%
  unique()

avgLD <- avgLD %>%
  left_join(map)

avgLD %>%
  ggplot(aes(x = BP_A, y = avgLD)) + 
  geom_point()

# find farthest away SNP with r^2 > 0.2
maxLD_02 <- ld %>%
  filter(R2 > 0.2) %>%
  group_by(SNP_A) %>%
  slice_max(dist_BP)

maxLD_02 %>%
  ggplot(aes(x = BP_A, y = dist_BP)) + 
  geom_point() + 
  labs(x = 'Position (bp)', y = 'Max distance to SNP with r^2 > 0.2')

# find farthest away SNP with r^2 > 0.1
maxLD_01 <- ld %>%
  filter(R2 > 0.1) %>%
  group_by(SNP_A) %>%
  slice_max(dist_BP)

maxLD_01 %>%
  ggplot(aes(x = BP_A, y = dist_BP)) + 
  geom_point() + 
  labs(x = 'Position (bp)', y = 'Max distance to SNP with r^2 > 0.1')


# density plot of r^2
ld %>%
  ggplot(aes(x = R2)) + 
  geom_density()

# bin by distance
ld %>%
  summary()
  mutate(dist_bin = cut(dist_BP, 100)) %>% 
  head()

# bin by r^2
