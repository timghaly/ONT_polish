# ONT_polish

This script takes a Nanopore assembly and runs four rounds of Racon polishing using MiniMap2 for read mapping, and then one round of Medaka polishing.

## Dependencies
[Minimap2 GitHub page](https://github.com/lh3/minimap2) and [Conda install](https://anaconda.org/bioconda/minimap2)

[Racon GitHub page](https://github.com/isovic/racon) and [Conda install](https://anaconda.org/bioconda/racon)

[Medaka GitHub page](https://github.com/nanoporetech/medaka) and [Conda install](https://anaconda.org/bioconda/medaka)

## Usage

```
usage: ./ONT_polish.sh -a <assembled contigs as fasta> -r <Nanopore reads as fastq> [optional arguments]

Mandatory arguments:
    -a : assembled contigs as fasta file
    -r : Nanopore reads as fastq (or fastq.gz) file
    
Optional arguments:
    -m : Medaka model | default: r941_min_hac_g507
    -t : number of CPUs | default: 1
    -o : output directory | default: current directory
```
