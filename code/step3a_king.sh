
pipeline=analysis_pipeline-master
config=config/king.config

python ${pipeline}/king.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json -c 1-22 $config
