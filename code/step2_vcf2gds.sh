## convert VCF to GDS file format
## relies on code from TOPMed Analysis Pipeline

pipeline=$1
config=$2

python ${pipeline}/vcf2gds.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json -c 1-22 $config

