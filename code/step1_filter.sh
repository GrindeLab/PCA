#!/bin/bash

qsub -q b-students.q -N filter -t 1-22 -pe local 2 run_job_array.sh filters.sh
