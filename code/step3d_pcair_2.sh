
pipeline=analysis_pipeline-master
config=config/pcair_round2.config

python ${pipeline}/pcair.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json -c 1-22 $config
