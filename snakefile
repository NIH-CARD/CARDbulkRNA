import pandas as pd
import os

"""========================================================================="""
"""                                 Parameters                              """
"""========================================================================="""


"""File locations"""
data_dir = '' # Define the data directory, explicitly
work_dir = '' # Define the working directory, explictly as the directory of this pipeline
metadata_table = work_dir+'/input/.csv' # Define where the metadata data exists for each sample to be processed
#More files to come!
"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""

rule fastqscreen:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/


rule umitools:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/

rule salmon:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/


rule star:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/

rule featurecounts:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/

rule multiqc:
    input:
        
    output:
        
    singularity:
        
    params:
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    script:
        work_dir+'/scripts/
