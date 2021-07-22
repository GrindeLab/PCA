#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -j y

args=("$@") # all arguments
scriptName=${args[0]} # pull out script name
unset args[0] # remove script name from arguments

./$scriptName $SGE_TASK_ID ${args[@]}

## USAGE: qsub -t 1-4 run_job_array.sh FILE_TO_RUN
