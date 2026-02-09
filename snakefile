import pandas as pd
import os

"""========================================================================="""
"""                                 Parameters                              """
"""========================================================================="""


"""File locations"""
configfile: "config/config.yaml"

data_dir = config['data_dir'] #define the data directory, explicitly
work_dir = config['work_dir'] #define the work directory, explicitly as the direcotry of this pipleine
genome_dir = config['genome_dir'] #define the genome directory, explicitly

"""Metadata parameters"""
samples=config['metadata_table']

# --- Grab FASTQ paths ---
def reads_for_sample(sample, col):
    rows = df[df["sample"] == sample]
    vals = [v for v in rows[col].tolist() if v and v.lower() != "nan"]
    if len(vals) == 0:
        raise ValueError(f"No {col} reads found for sample {sample}")
    return vals

def r1_list(wc): return reads_for_sample(wc.sample, "read1")
def r2_list(wc): return reads_for_sample(wc.sample, "read2")
"""========================================================================="""
"""                                  Workflow                               """
"""========================================================================="""
# Singularity containers


rule all:
    input:
        # concatenated fastqs
        expand("results/combined/{sample}_R1.fastq.gz", sample=samples),
        expand("results/combined/{sample}_R2.fastq.gz", sample=samples),

        # fastqc outputs
        expand("results/fastqc/{sample}_R1_fastqc.html", sample=samples),
        expand("results/fastqc/{sample}_R2_fastqc.html", sample=samples),
        "results/multiqc/multiqc_report.html",

        # STAR
        expand("results/star/{sample}.Aligned.sortedByCoord.out.bam", sample=samples),
        expand("results/star/{sample}.Aligned.sortedByCoord.out.bam.bai", sample=samples),

        # featureCounts
        "results/featurecounts/gene_counts.txt",
        "results/featurecounts/gene_counts.txt.summary",

        # Salmon
        expand("results/salmon/{sample}/quant.sf", sample=samples),

        # optional UMI outputs
        expand("results/umi/{sample}/dedup.bam", sample=samples) if config["umi"]["enabled"] else []

rule concatenate1:
    input: r1_list
    output: "results/combined/{sample}_combined_R1.fastq.gz"
    shell:
        r"""
        mkdir -p results/combined
        cat {input} > {output}
        """

rule concatenate2:
    input: r2_list
    output: "results/combined/{sample}_combined_R2.fastq.gz"
    shell:
        r"""
        mkdir -p results/combined
        cat {input} > {output}
        """

rule fastqc:
    input:
        samples
    output:
        r1 = f"{work_dir}/results/fastqc/{{sample}}_combined_R1_fastqc.html",
        r2 = f"{work_dir}/results/fastqc/{{sample}}_combined_R2_fastqc.html"
    threads: 4
    resources:
        mem_mb=64000,
        lscratch=80,
        slurm_partition="quick"
    shell:
        """
        module load fastqc
        mkdir -p {work_dir}/fastqc

        R1={input[0]}
        R2={input[1]}

        # Fastest: extract (no ZIP), run each read separately
        fastqc results/combined/*.fastq.gz -o /results/fastqc 
        """

rule multiqc:
    input:
        expand(f"{work_dir}/fastqc/*_fastqc.html", sample=samples),
    output:
        f"{work_dir}/results/multiqc/multiqc_report.html"
    resources:
        mem_mb=32000,
        slurm_partition="quick"
    shell:
        """
        module load multiqc
        mkdir -p {work_dir}/results/multiqc
        multiqc {work_dir}/results/fastqc -o {work_dir}/results/multiqc
        """

rule cutadapt:
    input:
        r1 = f"{data_dir}/{sample}_R1.fastq.gz",
        r2 = f"{data_dir}/{sample}_R2.fastq.gz"
    output:
        r1 = f"{work_dir}/cutadapt/{sample}_R1_trimmed.fastq.gz",
        r2 = f"{work_dir}/cutadapt/{sample}_R2_trimmed.fastq.gz"
    params:
        adapter_fwd = config["cutadapt"]["adapter_fwd"],
        adapter_rev = config["cutadapt"]["adapter_rev"]
    resources:
        mem_mb=64000,
        slurm_partition="quick"
    shell:
        """
        module load cutadapt
        mkdir -p {work_dir}/cutadapt
        cutadapt -j 10 -U 3 -o /{work_dir}/trimmed/{sample}_R1.fastq.gz \ -p /{work_dir}/trimmed/{sample}_R2.fastq.gz
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

