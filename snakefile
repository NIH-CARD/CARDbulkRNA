import pandas as pd
import os

"""========================================================================="""
"""                                 Parameters                              """
"""========================================================================="""


"""File locations"""
data_dir = '' # Define the data directory, explicitly
work_dir = '' # Define the working directory, explictly as the directory of this pipeline
metadata_table = work_dir+'/input/.csv' # Define where the metadata data exists for each sample to be processed

"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""

rule all:
    input:
        expand('fastqscreen_{sample}_done', sample=metadata_table['sample'])

"""
{% if config.pipe_params.screen %}
- name: fastqscreen_{{ sample }}
  after: cutadapt_{{ sample }}
  input: [{{ config.workdir }}, {{ parent_dirs.multi }}]
  output: fastqscreen_{{ sample }}_done
  cmd: |

    mkdir -p {{ config.workdir }}/fastq_screen/{{ sample }}
    cd {{ config.workdir }}/fastq_screen/{{ sample }}

    fastq_screen --conf {{ file_locations.fastq_screen_conf }} {{ config.workdir }}/trimmed/{{ sample }}/{{ sample }}_trimmed_R1_001.fastq.gz
{% endif %}
"""
rule fastqscreen:
    input:
        metadata_table
    output:
        'fastqscreen_{sample}_done'
    params:
        sample='{sample}',
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    shell:
        'module load fastq_screen/0.15.3; fastq_screen --conf'

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