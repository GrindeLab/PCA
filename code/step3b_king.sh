## Finding Unrelated Samples
## Step b: KING

pipeline=$1
config=$2

python ${pipeline}/king.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json -c 1-22 $config
