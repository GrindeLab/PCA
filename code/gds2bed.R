args <- commandArgs(TRUE)
gds.fn <- args[[1]]
samp.fn <- args[[2]]
snp.fn <- args[[3]]
out.fn <- args[[4]]

## load packages
library(gdsfmt)
library(SNPRelate)
library(SeqArray)

## getobj function
getobj <- function(Rdat){
  obj <- load(Rdat)
  return(eval(parse(text = obj)))
}


## load gds file
#(g <- openfn.gds(gds.fn))
#(g <- snpgdsOpen(gds.fn))
(g <- seqOpen(gds.fn))

## load unrelateds
samp.keep <- getobj(samp.fn)

## load pruned SNPs
snp.keep <- getobj(snp.fn)

## set filter
seqSetFilter(g, sample.id = samp.keep, variant.id = snp.keep)

## convert to SNP GDS format
seqGDS2SNP(g, 'gds/tmp.gds') 

## close seqgds
seqClose(g)

## open snpgds 
(gsnp <- snpgdsOpen('gds/tmp.gds'))

## convert GDS to BED
snpgdsGDS2BED(gdsobj = gsnp, bed.fn = out.fn, sample.id = samp.keep, snp.id = snp.keep, verbose = TRUE)
#snpgdsGDS2BED(gdsobj = g, bed.fn = out.fn, verbose = TRUE)

## close gds file
snpgdsClose(gsnp)
