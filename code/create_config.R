## UPDATE: Rscript create_config.R

create_config <- function(excl, r2, win, maf){
  out_prefix <- paste0('prune_', excl, '_', r2, '_', win, '_', maf)
  gds_file <- "gds/filtered_freeze5.gds"
  genome_build <- "hg38"
  sample_include_file <- "admixture_proportions/AA_admixture_unsup_K2.RData"
  exclude_pca_corr <- as.character(excl)
  ld_r_threshold <- as.character(r2)
  ld_win_size <- as.character(win)
  maf_threshold <- as.character(maf)
  config <- data.frame(col1 = c('out_prefix', 'gds_file', 'genome_build', 'sample_include_file', 'exclude_pca_corr', 'ld_r_threshold', 'ld_win_size', 'maf_threshold'), col2 = c(out_prefix, gds_file, genome_build, sample_include_file, exclude_pca_corr, ld_r_threshold, ld_win_size, maf_threshold))
  write.table(config, file = paste0('config/pca_', excl, '_', r2, '_', win, '_', maf, '.config'), row.names = F, col.names = F, quote = F)
}

# no filtering
create_config(FALSE, 1, 0, 0)

# MAF filtering only
create_config(FALSE, 1, 0, 0.01)

# exclude, but no prune
create_config(TRUE, 1, 0, 0.01)

# prune, no exclude
create_config(FALSE, 0.2, 0.5, 0.01)
create_config(FALSE, 0.1, 0.5, 0.01)
create_config(FALSE, 0.1, 10, 0.01)
create_config(FALSE, 0.05, 0.5, 0.01)

# prune and exclude
create_config(TRUE, 0.2, 0.5, 0.01)
create_config(TRUE, 0.1, 0.5, 0.01)
create_config(TRUE, 0.1, 10, 0.01)
create_config(TRUE, 0.05, 0.5, 0.01)

## add more?
