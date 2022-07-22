
create_config <- function(excl, r2, wdw, maf){
  config <- c(out_prefix = paste0('plots/prune_', excl, '_', r2, '_', wdw, '_', maf, '_snprelate_load'),
	      load_file = paste0('data/prune_', excl, '_', r2, '_', wdw, '_', maf, '_snprelate_load.RData'),
	      thin = TRUE)
  config.df <- data.frame(config)
  rownames(config.df) <- names(config)
  write.table(config, file = paste0('config/prune_', excl, '_', r2, '_', wdw, '_', maf, '_pca_load_plots.config'),
	row.names = T, col.names = F, quote = F)
}

# no filtering
create_config(FALSE, 1, 0, 0)

# MAF filtering
create_config(FALSE, 1, 0, 0.01)

# exclude, no prune
create_config(TRUE, 1, 0, 0.01)

# prune, no exclude
create_config(FALSE, 0.1, 0.5, 0.01)
create_config(FALSE, 0.1, 10, 0.01)
create_config(FALSE, 0.2, 0.5, 0.01)
create_config(FALSE, 0.05, 0.5, 0.01)

# prune and exclude
create_config(TRUE, 0.1, 0.5, 0.01)
create_config(TRUE, 0.1, 10, 0.01)
create_config(TRUE, 0.05, 0.5, 0.01)
create_config(TRUE, 0.2, 0.5, 0.01)

