
pipeline=analysis_pipeline-master
config=config/vcf2gds.config

python ${pipeline}/vcf2gds.py --cluster_file ${pipeline}/cluster_bstudents_cfg.json -c 1-22 $config
