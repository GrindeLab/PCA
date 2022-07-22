
## Usage:
## ./step5b_snprelate.sh config/pca_FALSE_0.05_0.5_0.01.config
## ./step5b_snprelate.sh config/pca_FALSE_0.1_0.5_0.01.config
## ./step5b_snprelate.sh config/pca_FALSE_0.1_10_0.01.config 
## ./step5b_snprelate.sh config/pca_FALSE_0.2_0.5_0.01.config
## ./step5b_snprelate.sh config/pca_FALSE_1_0_0.01.config 
## ./step5b_snprelate.sh config/pca_FALSE_1_0_0.config 	
## ./step5b_snprelate.sh config/pca_TRUE_0.05_0.5_0.01.config
## ./step5b_snprelate.sh config/pca_TRUE_0.1_0.5_0.01.config
## ./step5b_snprelate.sh config/pca_TRUE_0.1_10_0.01.config
## ./step5b_snprelate.sh config/pca_TRUE_0.2_0.5_0.01.config
## ./step5b_snprelate.sh config/pca_TRUE_1_0_0.01.config

config=$1

pipeline=analysis_pipeline-master

python ${pipeline}/snprelate.py --ld_pruning -c 1-22 --cluster_file ${pipeline}/cluster_bstudents_cfg.json $config
