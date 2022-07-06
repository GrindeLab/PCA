library(argparser)
# library(TopmedPipeline)
# BiocManager::install("gdsfmt")
library(gdsfmt)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
library(lazyeval)
# sessionInfo()

#### helper functions from TopmedPipeline package ####
readConfig <- function(file, ...) {
  config.table <- read.table(file, as.is=TRUE, ...)
  if (any(duplicated(config.table[, 1]))) stop("duplicated parameters in config file are not allowed!")
  config <- config.table[,2]
  names(config) <- config.table[,1]
  # recode tabs
  config[config %in% "\\t"] <- "\t"
  
  return(config)
}
setConfigDefaults <- function(config, required, optional) {
  # optional is a named list of default values
  default <- unname(optional)
  optional <- names(optional)
  
  config.params <- names(config)
  found.params <- intersect(config.params, c(required, optional))
  if (length(found.params) > 0) {
    message("found parameters: ", paste(found.params, collapse=", "))
  }
  
  # if required params not in config, stop
  missing.params <- setdiff(required, config.params)
  if (length(missing.params) > 0) {
    stop("missing required parameters: ", paste(missing.params, collapse=", "))
  }
  
  # if not in config, set default value
  set.params <- setdiff(optional, config.params)
  if (length(set.params) > 0) {
    config[set.params] <- default[match(set.params, optional)]
    message("using default values: ", paste(set.params, collapse=", "))
  }
  
  # note unsed params in config
  extra.params <- setdiff(config.params, c(required, optional))
  if (length(extra.params) > 0) {
    message("unused parameters: ", paste(extra.params, collapse=", "))
  }
  
  # return config with default values set
  config <- config[c(required, optional)]
  return(config)
}
insertChromString <- function(x, chr, err=NULL) {
  if (!is.null(err) & !(grepl(" ", x, fixed=TRUE))) {
    stop(paste(err, "must have a blank space to insert chromosome number"))
  }
  sub(" ", chr, x, fixed=TRUE)
}
thinPoints <- function(dat, value, n=10000, nbins=10, groupBy=NULL){
  if (!is.null(groupBy)) {
    dat <- group_by_(dat, groupBy)
  }
  
  dat %>%
    mutate_(bin=interp(~cut(value, breaks=nbins, labels=FALSE), value=as.name(value), nbins=nbins)) %>%
    group_by_(~bin, add=TRUE) %>%
    sample_frac(1) %>%
    filter_(~(row_number() <= n)) %>%
    ungroup() %>%
    select_(.dots="-bin")
}


#### read config file ####
# argp <- arg_parser("PCA correlation plots")
# argp <- add_argument(argp, "config", help="path to config file")
# argp <- add_argument(argp, "--version", help="pipeline version number")
# argv <- parse_args(argp)
# cat(">>> TopmedPipeline version ", argv$version, "\n")
# config <- readConfig(argv$config)
config <- readConfig("prune_FALSE_1_0_0.01_snprelate_corr_plots.config")

required <- c("corr_file")
optional <- c("chromosomes"="1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22",
              "n_pcs"=20,
              "n_perpage"=4,
              "out_prefix"="pca_corr",
              "thin"=TRUE)
config <- setConfigDefaults(config, required, optional)
print(config)

chr <- strsplit(config["chromosomes"], " ", fixed=TRUE)[[1]]
files <- sapply(chr, function(c) insertChromString(config["corr_file"], c, "corr_file"))

corr <- do.call(rbind, lapply(unname(files), function(f) {
  print('opening GDS')
  c <- openfn.gds(f)
  dat <- t(read.gdsn(index.gdsn(c, "correlation")))
  n_pcs <- min(as.integer(config["n_pcs"]), ncol(dat))
  dat <- dat[,1:n_pcs]
  missing <- rowSums(is.na(dat)) == n_pcs # monomorphic variants
  dat <- dat[!missing,]
  colnames(dat) <- paste0("PC", 1:n_pcs)
  dat <- data.frame(dat,
                    chr=readex.gdsn(index.gdsn(c, "chromosome"), sel=!missing),
                    pos=readex.gdsn(index.gdsn(c, "position"), sel=!missing),
                    stringsAsFactors=FALSE)
  closefn.gds(c)
  
  ## transform to data frame with PC as column
  #print('transforming data')
  dat <- dat %>%
    gather(PC, value, -chr, -pos) %>%
    filter(!is.na(value)) %>%
    mutate(value=abs(value)) %>%
    mutate(PC=factor(PC, levels=paste0("PC", 1:n_pcs)))
  
  ## thin points
  ## take up to 10,000 points from each of 10 evenly spaced bins
  #print('thinning points')
  if (as.logical(config["thin"])) {
    #dat <- thinPoints(dat, "value", n=10000, nbins=10, groupBy="PC")
    dat <- thinPoints(dat, "value", n=1000, nbins=10, groupBy="PC")
  }
  
  dat
}))

## make chromosome a factor so they are plotted in order
corr <- mutate(corr, chr=factor(chr, levels=c(1:22, "X")))
chr <- levels(corr$chr)
cmap <- setNames(rep_len(brewer.pal(8, "Dark2"), length(chr)), chr)

# plot over multiple pages
n_pcs <- length(unique(corr$PC))
n_plots <- ceiling(n_pcs/as.integer(config["n_perpage"]))
bins <- as.integer(cut(1:n_pcs, n_plots))
n_plots <- 1 ## override to just make first plot
for (i in 1:n_plots) {
  bin <- paste0("PC", which(bins == i))
  dat <- filter(corr, PC %in% bin)
  
  p <- ggplot(dat, aes(chr, value, group=interaction(chr, pos), color=chr)) +
    geom_point(position=position_dodge(0.8)) +
    facet_wrap(~PC, scales="free", ncol=1) +
    scale_color_manual(values=cmap, breaks=names(cmap)) +
    ylim(0,1) +
    theme_bw() +
    theme(legend.position="none") +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
    xlab("Chromosome") + ylab("Correlation (absolute value)")+
    theme(text = element_text(size = 24))
  save(p, file = paste0(config['out_prefix'], '_', i, '.RData'))
  ggsave(paste0(config["out_prefix"], "_" , i, ".png"), plot=p, width=10, height=15)
}

# mem stats
ms <- gc()
cat(">>> Max memory: ", ms[1,6]+ms[2,6], " MB\n")