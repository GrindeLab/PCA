## perform LD pruning
## recommended for PC-AiR (finding unrelated) and ADMIXTURE (finding admixed)

pipeline=$1
config=$2

python ${pipeline}/ld_pruning.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json -c 1-22 $config
