#!/bin/bash

#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu=32G
#SBATCH --time 96:00:00

module purge
module load apptainer
module load snakemake

# Pull profile, this will only run once, and is required for running on Biowulf
git clone https://github.com/NIH-HPC/snakemake_profile.git

# Load singularity
module load singularity

# Bind external directories on Biowulf
. /usr/local/current/singularity/app_conf/sing_binds

# RUN SCRIPT
snakemake --cores all --profile snakemake_profile --use-singularity