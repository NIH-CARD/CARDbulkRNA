import pandas as pd
import os

"""========================================================================="""
"""                                 Parameters                              """
"""========================================================================="""


"""File locations"""
data_dir = "/data/CARD_ARDIS/" #define the data directory, explicitly
work_dir = os.getcwd() #define the work directory, explicitly as the direcotry of this pipleine
genome_dir = "/data/CARD_ARDIS/" #define the genome directory, explicitly

"""Metadata parameters"""
samples=pd.read_csv(metadata_table)


# --- Grab FASTQ paths ---
import glob

#def get_fastqs(wc):
#    sample = wc.sample
#
#    r1 = sorted(glob.glob(os.path.join(DATA_DIR, f"{sample}*R1*.fastq*")))
#    r2 = sorted(glob.glob(os.path.join(DATA_DIR, f"{sample}*R2*.fastq*")))
#
#    if not r1 or not r2:
 #       raise FileNotFoundError(f"Missing R1 or R2 FASTQ for {sample} in {DATA_DIR}")
#
#    return [r1[0], r2[0]]
"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""
# Singularity containers


rule all:
    input:
        expand(f"{work_dir}/fastqc/{{sample}}_R1_fastqc.html", sample=samples),
        expand(f"{work_dir}/fastqc/{{sample}}_R2_fastqc.html", sample=samples),
        f"{work_dir}/multiqc/multiqc_report.html"

rule fastqc:
    input:
        samples
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
        expand(f"{work_dir}/fastqc/{{sample}}_R1_fastqc.html", sample=samples),
        expand(f"{work_dir}/fastqc/{{sample}}_R2_fastqc.html", sample=samples)
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

