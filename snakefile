import pandas as pd
import os

"""========================================================================="""
"""                                 Parameters                              """
"""========================================================================="""


"""File locations"""
data_dir = '' # Define the data directory, explicitly
work_dir = '' # Define the working directory, explictly as the directory of this pipeline
metadata_table = work_dir+'/input/.csv' # Define where the metadata data exists for each sample to be processed
metadata_df = pd.read_csv(metadata_table)

"""Config file location"""
configfile: "path/to/config.yaml"

"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""

rule all:
    input:
        expand('fastqscreen_{sample}_done', sample=metadata_df['sample'])

rule fastqscreen:
    input:
        '{file_locations.fastq_screen_conf}'
    output:
        '{config.workdir}/trimmed/{sample}/{sample}_trimmed_R1_001.fastq.gz'
    params:
        sample='{sample}',
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    shell:
        'module load fastq_screen/0.15.3; fastq_screen --conf {file_locations.fastq_screen_conf} {config.workdir}/trimmed/{sample}/{sample}_trimmed_R1_001.fastq.gz'

"""
rule umitools:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/'

rule salmon:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/'


rule star:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/'

rule featurecounts:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/'

rule multiqc:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/'
"""