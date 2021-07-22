## convert VCF to GDS file format
## relies on code from TOPMed Analysis Pipeline

pipeline=$1
email=$2
config=$3

python ${pipeline}/vcf2gds.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json -e $email -c 1-22 $config

