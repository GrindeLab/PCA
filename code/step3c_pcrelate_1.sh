
pipeline=analysis_pipeline-master
config=config/pcrelate_round1.config

python ${pipeline}/pcrelate.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json $config
