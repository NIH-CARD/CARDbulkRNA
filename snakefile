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
import glob

def get_fastqs(wc):
    sample = wc.sample

    r1 = sorted(glob.glob(os.path.join(DATA_DIR, f"{sample}*R1*.fastq*")))
    r2 = sorted(glob.glob(os.path.join(DATA_DIR, f"{sample}*R2*.fastq*")))

    if not r1 or not r2:
        raise FileNotFoundError(f"Missing R1 or R2 FASTQ for {sample} in {DATA_DIR}")

    return [r1[0], r2[0]]
"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""

rule all:
    input:
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R1_fastqc.html", sample=SAMPLES),
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R2_fastqc.html", sample=SAMPLES),
        f"{WORK_DIR}/multiqc/multiqc_report.html"

rule fastqc:
    input:
        get_fastqs
    output:
        r1 = f"{WORK_DIR}/fastqc/{{sample}}_R1_fastqc.html",
        r2 = f"{WORK_DIR}/fastqc/{{sample}}_R2_fastqc.html"
    threads: 4
    resources:
        mem_mb=64000,
        lscratch=80,
        slurm_partition="quick"
    shell:
        """
        module load fastqc
        mkdir -p $LSCRATCH {WORK_DIR}/fastqc

        R1={input[0]}
        R2={input[1]}

        # Fastest: extract (no ZIP), run each read separately
        fastqc --extract -t {threads} --dir $LSCRATCH -o $LSCRATCH $R1
        fastqc --extract -t {threads} --dir $LSCRATCH -o $LSCRATCH $R2
        """


rule multiqc:
    input:
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R1_fastqc.html", sample=SAMPLES),
        expand(f"{WORK_DIR}/fastqc/{{sample}}_R2_fastqc.html", sample=SAMPLES)
    output:
        f"{WORK_DIR}/multiqc/multiqc_report.html"
    resources:
        mem_mb=32000,
        slurm_partition="quick"
    shell:
        """
        module load multiqc
        mkdir -p {WORK_DIR}/multiqc
        multiqc {WORK_DIR}/fastqc -o {WORK_DIR}/multiqc
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

