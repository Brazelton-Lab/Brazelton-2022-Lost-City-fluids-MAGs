#! /bin/sh
#SBATCH --ntasks 12
#SBATCH --nodes 1
#SBATCH --partition highmem
#SBATCH --mem 100G
#SBATCH --output reassembly.out
#SBATCH --error reassembly.err

# replace YOUR-ASSEMBLY-NAME with actual assembly name
ASSEMBLY=YOUR-ASSEMBLY-NAME
SAMPLES=samples.txt

# build bowtie database from source bins
bowtie2-build "$ASSEMBLY".fa "$ASSEMBLY"

# map reads and extract pairs and singletons into separate bam files
for sample in `awk '{print $1}' $SAMPLES`
do
    bowtie2 --threads 12 -x "$ASSEMBLY" --interleaved /srv/data/mg/projects/LCY/LC2018/qc_reads/"$sample".interleaved.atrim.decontam.qtrim.fq.gz --no-unal -S "$sample"_mapped_to_"$ASSEMBLY".sam 2>> "$sample"_mapped_to_"$ASSEMBLY".mapping.log
    samtools view -F 4 -f 8 -bh "$sample"_mapped_to_"$ASSEMBLY".sam > "$sample"_mapped_to_"$ASSEMBLY"_singles1.bam
    samtools view -F 8 -f 4 -bh "$sample"_mapped_to_"$ASSEMBLY".sam > "$sample"_mapped_to_"$ASSEMBLY"_singles2.bam
    samtools view -F 12 -bh "$sample"_mapped_to_"$ASSEMBLY".sam > "$sample"_mapped_to_"$ASSEMBLY"_paired.bam
done

# convert bam files to fastq files
samtools merge "$ASSEMBLY"_all_mapped_singletons.bam LC18d001_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d002_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d003_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d003_02_mapped_to_"$ASSEMBLY"_singles1.bam LC18d004_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d007_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d008_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d009_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d009_02_mapped_to_"$ASSEMBLY"_singles1.bam LC18d010_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d011_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d016_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d017_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d018_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d019_01_mapped_to_"$ASSEMBLY"_singles1.bam LC18d001_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d002_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d003_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d003_02_mapped_to_"$ASSEMBLY"_singles2.bam LC18d004_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d007_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d008_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d009_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d009_02_mapped_to_"$ASSEMBLY"_singles2.bam LC18d010_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d011_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d016_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d017_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d018_01_mapped_to_"$ASSEMBLY"_singles2.bam LC18d019_01_mapped_to_"$ASSEMBLY"_singles2.bam
samtools merge "$ASSEMBLY"_all_mapped_pairs.bam LC18d001_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d002_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d003_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d003_02_mapped_to_"$ASSEMBLY"_paired.bam LC18d004_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d007_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d008_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d009_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d009_02_mapped_to_"$ASSEMBLY"_paired.bam LC18d010_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d011_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d016_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d017_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d018_01_mapped_to_"$ASSEMBLY"_paired.bam LC18d019_01_mapped_to_"$ASSEMBLY"_paired.bam
samtools sort -n -o "$ASSEMBLY"_all_mapped_singletons.sorted-n.bam "$ASSEMBLY"_all_mapped_singletons.bam
samtools sort -n -o "$ASSEMBLY"_all_mapped_pairs.sorted-n.bam "$ASSEMBLY"_all_mapped_pairs.bam
samtools fastq -1 "$ASSEMBLY"_all_mapped_pairs.sorted-n.Freads.fq -2 "$ASSEMBLY"_all_mapped_pairs.sorted-n.Rreads.fq "$ASSEMBLY"_all_mapped_pairs.sorted-n.bam
samtools fastq -1 "$ASSEMBLY"_all_mapped_singletons1.sorted-n.fq -2 "$ASSEMBLY"_all_mapped_singletons2.sorted-n.fq "$ASSEMBLY"_all_mapped_singletons.sorted-n.bam
cat "$ASSEMBLY"_all_mapped_singletons1.sorted-n.fq "$ASSEMBLY"_all_mapped_singletons2.sorted-n.fq > "$ASSEMBLY"_all_mapped_singletons12.sorted-n.fq

fastq-summary.py .fq > "$ASSEMBLY"-number-of-extracted-reads.txt

# metaspades assembly
spades.py --threads 12 --phred-offset 33 --only-assembler --meta -1 "$ASSEMBLY"_all_mapped_pairs.sorted-n.Freads.fq -2 "$ASSEMBLY"_all_mapped_pairs.sorted-n.Rreads.fq -s "$ASSEMBLY"_all_mapped_singletons12.sorted-n.fq -o "$ASSEMBLY"_metaspades &> "$ASSEMBLY"_metaspades.log

# metaquast
metaquast.py -o assembly_stats --fast --max-ref-number 0 --labels "$ASSEMBLY" "$ASSEMBLY"_metaspades/scaffolds.fasta

# need to rename contigs for downstream compatibility with anvio
anvi-script-reformat-fasta "$ASSEMBLY"_metaspades/scaffolds.fasta -o "$ASSEMBLY"_metaspades.scaffolds.renamed.fa -l 0 --simplify-names --report-file "$ASSEMBLY"_metaspades.names_map.tsv

# get coverages
mkdir coverages
cp "$SAMPLES" coverages/
cd coverages
bowtie2-build ../"$ASSEMBLY"_metaspades.scaffolds.renamed.fa "$ASSEMBLY"_metaspades

NEWASSEMBLY="$ASSEMBLY"_metaspades
for sample in `awk '{print $1}' "$SAMPLES"`
do
    bowtie2 --threads 12 -x "$NEWASSEMBLY" --interleaved /srv/data/mg/projects/LCY/LC2018/qc_reads/"$sample".interleaved.atrim.decontam.qtrim.fq.gz --no-unal -S "$sample"_mapped_to_"$NEWASSEMBLY".sam 2>> "$sample"_mapped_to_"$NEWASSEMBLY".mapping.log
    samtools view -F 4 -bh "$sample"_mapped_to_"$NEWASSEMBLY".sam > "$sample"_mapped_to_"$NEWASSEMBLY"_RAW.bam
    anvi-init-bam "$sample"_mapped_to_"$NEWASSEMBLY"_RAW.bam -o "$sample"_mapped_to_"$NEWASSEMBLY".bam
    rm "$sample"_mapped_to_"$NEWASSEMBLY".sam "$sample"_mapped_to_"$NEWASSEMBLY"_RAW.bam
done