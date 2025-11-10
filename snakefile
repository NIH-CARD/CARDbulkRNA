import pandas as pd
import os

"""========================================================================="""
"""                                 Parameters                              """
"""========================================================================="""


"""File locations"""
data_dir = '' # Define the data directory, explicitly
work_dir = '' # Define the working directory, explictly as the directory of this pipeline
metadata_table = config['metadata_file']# Define where the metadata data exists for each sample to be processed
metadata_df = pd.read_csv(metadata_table)

"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""

rule all: 
    input:
        expand(f"{work_dir}/fastqc/{{sample}}_fastqc.html", 
               sample=metadata_df.sample),
        expand(f"{work_dir}/fastqc/{{sample}}_fastqc.zip", 
               sample=metadata_df.sample),
               f"{work_dir}/multiqc/multiqc_report.html"

rule fastqc:
    input:
        fastq = lambda wc: f"{data_dir}/{wc.sample}.fastq.gz"
        
    output:
        html=f'{config.workdir}/fastqc/{sample}.fastqc.html',
        zip=f'{config.workdir}/fastqc/{sample}.fastqc.zip'
        
    params:'{sample}',
        
    resources:
        runtime=120, mem_mb=64000, disk_mb=10000, slurm_partition='quick' 
    shell:
        """
        module load fastqc/0.12.1 
        mkdir -p {work_dir}/fastqc/ 
        fastqc -o {work_dir}/fastqc/{input.fastq} 
        """

rule multiqc:
    input:
        expand(f"{work_dir}/fastqc/{{sample}}_fastqc.zip", 
               sample=metadata_df.sample)
    output:
        f"{work_dir}/multiqc/multiqc_report.html"
    resources:
        runtime=60, mem_mb=32000, disk_mb=10000, slurm_partition='quick' 
    shell:
        """
        module load multiqc/1.9
        mkdir -p {work_dir}/multiqc/
        multiqc {work_dir}/fastqc/ -o {work_dir}/multiqc/
        """ 

rule star_alignment:
    input:
        fastq = lambda wc: f"{data_dir}/{wc.sample}.fastq.gz"
        
    output:
        bam=f'{work_dir}/star/{sample}.Aligned.sortedByCoord.out.bam'
        
    params:'{sample}',
        
    resources:
        runtime=240, mem_mb=128000, disk_mb=50000, slurm_partition='long' 
    shell:
        """
        module load star/2.7.3a
        mkdir -p {work_dir}/star/ 
        STAR --runThreadN 8 --genomeDir /path/to/genome/index/ \
             --readFilesIn {input.fastq} --readFilesCommand zcat \
             --outFileNamePrefix {work_dir}/star/{params.sample}. \
             --outSAMtype BAM SortedByCoordinate
        """

