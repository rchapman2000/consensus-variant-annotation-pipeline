# Nextflow Variant Annotation Pipeline
This pipeline identifies and annotates variants in full genome sequences compared to a desired reference sequence. The pipeline works by performing the following steps:

1. Align genomes in FASTA format to a reference.
2. Call variants and split them into SNPs and Indels
3. Annotate the variants using SNPEff

## Technical Considerations

### SNPEff Database

A **pre-requisite step** of this pipeline is configuring your desired SNPEff database (if this does not exist already). If you installed the pipeline using the [Installation instructions](##Installation) included in this README, then you will need to modify the SNPEff database files found in the conda environment you created.

The guide for creating a SNPEff database and modifying these files can be found in the [SNPEff documentation](https://pcingola.github.io/SnpEff/se_buildingdb/).

To find the files mentioned in this guide, you will need to navigate into your conda environment:
- If you have installed conda typical way, the environments will be located in the following directory (replacing \<USER\> and [anaconda3 or miniconda3] with the directories found on your device): ```/home/<USER>/[anaconda3 or miniconda3]/envs/```
- Inside of the ```envs``` directory, navigate into ```Variant-Annotation/share/snpeff-5.1.2/```

## Installation

To install this pipeline, enter the following commands:

1. Clone the repository
```
git clone https://github.com/rchapman2000/consensus-variant-annotation-pipeline
```

2. Create a conda environment using the provided environment.yml file
```
conda env create -f environment.yml
```

3. Activate the conda environment
```
conda activate Variant-Annotation
```
4. Ensure that you have configured your [SNPEff Database](###SNPEffDatabase)

### Updating the Pipeline
If you already have the pipeline installed, you can update it using the following commands:

1. Navigate to your installation directory
```
cd consensus-variant-annotation-pipeline
```

2. Use ```git pull``` to get the latest update
```
git pull
```
3. Activate the conda environment and use the environment.yml file to download updates
```
conda activate Variant-Annotation

conda env update --file environment.yml --prune
```
4. Navigate to your [SNPEff Database Directory](###SNPEffDatabase) and ensure those you have created have not been modified.

## Usage
To run the pipeline, use the following command:
```
# You must either be in the same directory as the main.nf file or reference the file location.
nextflow run main.nf [options] --input INPUT_DIR --output OUTPUT_DIR --reference REFERENCE_FASTA --snpEffDB DATABASE_NAME 
```