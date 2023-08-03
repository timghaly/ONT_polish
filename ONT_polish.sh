#!/bin/bash

usage() {
  printf "\nusage: ./ONT_polish.sh -a <assembled contigs as fasta> -r <Nanopore reads as fastq> [optional arguments]\n\nMandatory arguments:\n-a : assembled contigs as fasta file \n-r : Nanopore reads as fastq (or fastq.gz) file\n\nOptional arguments:\n-m : Medaka model | default: r941_min_hac_g507\n-t : number of CPUs | default: 1 \n-o : output directory | default: current directory\n\nDependencies:\nMinimap2\nRacon\nMedaka\n\n"
  exit 0
}

[ $# -eq 0 ] && usage

while getopts a:r:m:t:o: flag
do
  case "${flag}" in
    a) ctg=${OPTARG};;
    r) reads=${OPTARG};;
    m) model=${OPTARG};;
    t) threads=${OPTARG};;
    o) outdir=${OPTARG};;
    *) usage exit 0;;
  esac
done

if [ -z "$threads" ]
then
  threads="1"
fi

if [ -z "$outdir" ]
then
  outdir="."
fi

if [ -z "$model" ]
then
  model="r941_min_hac_g507"
fi

if [ -z "$ctg" ]
then
  printf "\nMissing: -a <assembled contigs as fasta>\n" >&2
  usage
  exit 0
fi

if [ -z "$reads" ]
then
  printf "\nMissing: -r <Nanopore reads as fastq>\n" >&2
  usage
  exit 0
fi

# Extract sample name from contig file
name=$(basename "$ctg" | rev | cut -d'.' -f2- | rev)

# Polishing iterations
maxiter=4

# Setup initial contig files safely
cp $ctg tmp.0.fasta

echo '#################################################'
echo 'Starting Minimap and Racon'
echo '#################################################'

# Minimap and Racon
for ((i=1; i<=$maxiter; i++))
do
  echo '#################################################'
  echo 'Minimap round: ' $i
  echo '#################################################'
  h=$(expr $i - 1)

  minimap2 -x map-ont -t $threads tmp.$h.fasta $reads > tmp.$i.paf

  echo '#################################################'
  echo 'Racon round: ' $i
  echo '#################################################'

  racon -m 8 -x -6 -g -8 -w 500 -t $threads $reads tmp.$i.paf tmp.$h.fasta > tmp.$i.fasta
done

mv tmp.4.fasta $outdir/$name.4xracon.fasta
rm tmp*

echo '#################################################'
echo 'Finished Minimap and Racon'
echo '#################################################'
echo 'Starting Medaka'
echo '#################################################'

medaka_consensus -i $reads -d $outdir/$name.4xracon.fasta -m $model -o $outdir/$name.medaka -t $threads

rm $outdir/$name.4xracon.*
mv $outdir/$name.medaka/consensus.fasta $outdir/$name.medaka/$name.consensus.fasta

echo '#################################################'
echo 'Finished Medaka'
echo '#################################################'
echo 'ONT_polish.sh has finished'
echo '#################################################'
