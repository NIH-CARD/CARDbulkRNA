import pandas as pd
import os

"""========================================================================="""
"""                                 Parameters                              """
"""========================================================================="""


"""File locations"""
configfile: "config.yaml"
metadata_table = config['metadata_file']
metadata_df = pd.read_csv(metadata_table)
SAMPLES = metadata_df['sampleID'].tolist()

DATA_DIR = config['data_dir'] 
WORK_DIR = config['work_dir'] 
GENOME_DIR = config['genome_dir'] 

LAYOUT = config['layout'].upper()

# --- Grab FASTQ paths ---
def get_fastqs(wildcards):
    sample = wildcards.sample
    if LAYOUT == "PE":
        return [
            os.path.join(DATA_DIR, f"{sample}_R1.fastq.gz"),
            os.path.join(DATA_DIR, f"{sample}_R2.fastq.gz")
        ]
    elif LAYOUT == "SE":
        return [os.path.join(DATA_DIR, f"{sample}.fastq.gz")]
    else:
        raise ValueError(f"Unknown layout '{LAYOUT}' (expected PE or SE)")

"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""

rule all: 
    input:
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R1_fastqc.html", sample=SAMPLES),
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R2_fastqc.html", sample=SAMPLES) if LAYOUT == "PE" else [],
        f"{WORK_DIR}/multiqc/multiqc_report.html"


rule fastqc:
    input:
        get_fastqs
    output:
        html = expand(f"{WORK_DIR}/fastqc/{{sample}}_{{read}}_fastqc.html",
                      sample=lambda wc: wc.sample,
                      read=["R1", "R2"] if LAYOUT == "PE" else ["R1"]),
        zip = expand(f"{WORK_DIR}/fastqc/{{sample}}_{{read}}_fastqc.zip",
                     sample=lambda wc: wc.sample,
                     read=["R1", "R2"] if LAYOUT == "PE" else ["R1"]),
    threads: 2
    resources:
        runtime=120,
        mem_mb=64000,
        disk_mb=10000,
        slurm_partition='quick'
    shell:
        """
        module load fastqc/0.12.1
        mkdir -p {WORK_DIR}/fastqc
        fastqc -t {threads} -o {WORK_DIR}/fastqc {input}
        """

rule multiqc:
   input:
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R1_fastqc.html", sample=SAMPLES),
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R2_fastqc.html", sample=SAMPLES) if LAYOUT == "PE" else []
   output:
        f"{WORK_DIR}/multiqc/multiqc_report.html"
   resources:
        runtime=60, mem_mb=32000, disk_mb=10000, slurm_partition='quick' 
   shell:
        """
        module load multiqc/1.9
        mkdir -p {work_dir}/multiqc/
        multiqc {work_dir}/fastqc/ -o {work_dir}/multiqc
        """ 

#rule star_alignment:
#    input:
#        fastq = lambda wc: f"{data_dir}/{wc.sample}.fastq.gz"
#        
#    output:
#        bam=f'{work_dir}/star/{sample}.Aligned.sortedByCoord.out.bam'
#        
#    params:'{sample}',
#        
#    resources:
#        runtime=240, mem_mb=128000, disk_mb=50000, slurm_partition='long' 
#    shell:
#        """
#        module load star/2.7.3a
#        mkdir -p {work_dir}/star/ 
#        STAR --runThreadN 8 --genomeDir /path/to/genome/index/ \
#             --readFilesIn {input.fastq} --readFilesCommand zcat \
#             --outFileNamePrefix {work_dir}/star/{params.sample}. \
#             --outSAMtype BAM SortedByCoordinate
#       """

