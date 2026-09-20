# Comparative genomic analysis of the mcr-9.1 region in *Cronobacter sakazakii*

## Overview

This repository contains the supporting data, analysis scripts, phylogenetic files, and annotation files used in the study:

**Comparative genomic analysis of the mcr-9.1 region reveals structural diversity across *Cronobacter sakazakii* lineages**

The study investigates the genomic organization and diversity of the **mcr-9.1** region among *Cronobacter sakazakii* genomes, with emphasis on genetic context, sequence type, predicted genomic localization, assembly characteristics, temporal distribution, geographic distribution, and source of isolation.

No new sequencing data were generated for this study. Genome assemblies analysed in this work were obtained from the **NCBI Assembly database**. The accession number for each genome is provided in Table 1 of the manuscript.

---

## Repository contents

### Data files

| File                                        | Description                                                                                                                |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `mcr9_genetic_context.csv`                  | Final metadata and genomic-context dataset for the 38 *C. sakazakii* isolates analysed in the study.                       |
| `Supplement Table 1.xlsx`                   | Supplementary Table 1 containing isolate metadata, genomic characteristics, accession information, and analysis variables. |
| `gene_presence_absence_phandango_clean.csv` | Processed gene presence/absence data used for phylogenetic visualization and annotation.                                   |
| `phandango.csv`                             | Phandango-compatible annotation data associated with the core-genome phylogeny.                                            |

The file `mcr9_genetic_context.csv` corresponds to the final dataset used for the analyses reported in the manuscript.

---

## Analysis scripts

The repository contains R scripts used for the statistical analyses and generation of Figures 2–5.

| Script                            | Purpose                                                                                                                |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `statistics.R`                    | Statistical analyses of genomic-context complexity, sequence type, genomic localization, and assembly characteristics. |
| `figure2_genomic_context.R`       | Generation of Figure 2 showing the genomic organization of the mcr-9.1 region.                                         |
| `figure3_assembly_quality.R`      | Analysis and visualization of assembly quality metrics, including N50 and contig number.                               |
| `figure4_temporal_distribution.R` | Generation of Figure 4 showing the temporal distribution of the analysed isolates.                                     |
| `figure5_geographic_source.R`     | Generation of Figure 5 showing geographic distribution and source of isolation.                                        |

The scripts were developed and executed using **R 4.6.0**.

---

## Phylogenetic files

The repository includes files associated with the core-genome phylogenetic analysis and visualization:

* `core_gene_alignment.phandango.tre`
* `Cronobacter_mcr9_final.treefile`
* `Cronobacter_mcr9_final.contree`
* `phandango.csv`
* `gene_presence_absence_phandango_clean.csv`

The phylogenetic files were used for visualization and annotation of the analysed *C. sakazakii* isolates.

---

## iTOL annotation files

The following files contain annotation datasets used for visualization of the phylogenetic tree in the **Interactive Tree of Life (iTOL)**:

* `iTOL_01_ST_colorstrip.txt` — sequence-type annotation
* `iTOL_02_isolation_year_gradient.txt` — isolation-year annotation
* `iTOL_03_mcr9_localization.txt` — predicted mcr-9.1 genomic localization
* `iTOL_04_ST_branch_colors.txt` — sequence-type branch-color annotation

These files can be used with the corresponding phylogenetic tree in iTOL to reproduce the tree annotations used in the study.

---

## Genome data

All genome assemblies analysed in this study were obtained from the **NCBI Assembly database** and are publicly available under the accession numbers listed in Table 1 of the manuscript.

No new sequencing data were generated as part of this study.

The NCBI accession numbers provide the primary source records for the genome assemblies used in the comparative genomic analyses.

The genome assemblies themselves are not redistributed in this repository because they are publicly available through NCBI.

---

## Study dataset

The final dataset comprises **38 mcr-9.1-positive *Cronobacter sakazakii* genomes**.

The dataset includes information on:

* NCBI accession
* sequence type (ST)
* isolation year
* country
* source of isolation
* predicted mcr-9.1 localization
* assembly quality metrics
* genomic-context features
* mcr-9.1-associated genes and genetic elements
* genomic-context complexity

The dataset was used as the basis for the statistical analyses and figures reported in the manuscript.

---

## Software and tools

The analyses were performed using the following software and tools:

| Software / tool   | Version                   |
| ----------------- | ------------------------- |
| R                 | 4.6.0                     |
| Biopython         | 1.88                      |
| Panaroo           | 1.1.2                     |
| Gubbins           | 3.4.3                     |
| IQ-TREE           | 2.4.0                     |
| RAxML-NG          | 2.0.2                     |
| ResFinder         | 4.7.2                     |
| MOB-suite         | Version used in the study |
| PlasmidFinder     | Version used in the study |
| ggplot2           | R package                 |
| gggenes           | 0.7.0                     |
| dplyr             | R package                 |
| sf                | R package                 |
| rnaturalearth     | R package                 |
| rnaturalearthdata | R package                 |
| patchwork         | R package                 |

Software versions are reported where available to facilitate reproducibility of the analyses.

---

## Reproducibility

The repository provides the final supporting datasets, analysis scripts, phylogenetic files, and visualization annotation files required to reproduce the principal statistical analyses and figures reported in the manuscript.

To reproduce the analyses, users should:

1. Obtain the corresponding genome assemblies from the NCBI Assembly database using the accession numbers provided in Table 1 of the manuscript.
2. Use the supporting datasets provided in this repository.
3. Run the corresponding R scripts for the statistical analyses and figures.
4. Use the provided phylogenetic and iTOL annotation files for phylogenetic visualization.

The genome assemblies are not redistributed in this repository because they are publicly available through NCBI.

Because software versions, databases, and external genome records may change over time, exact reproduction may require use of the software versions specified above and the same accession records used in the study.

---

## Data availability

No new sequencing data were generated in this study.

All genome assemblies analysed in this work are publicly available through the **NCBI Assembly database** under the accession numbers listed in Table 1 of the manuscript.

The supporting datasets, analysis scripts, phylogenetic files, and visualization annotation files required to reproduce the reported analyses are provided in this repository.

A version of this repository will be archived through **Zenodo** to provide a persistent DOI for citation and long-term access.

**Zenodo DOI:** To be added after publication of the repository release.

---

## Citation

If you use the data or scripts from this repository, please cite the associated manuscript and the archived Zenodo version of this repository.

### Manuscript

Ali, S.S. *Comparative genomic analysis of the mcr-9.1 region reveals structural diversity across Cronobacter sakazakii lineages.*

### Repository

Ali, S.S. *mcr-9.1-Cronobacter-genomic-analysis*. Zenodo. DOI: To be added.

---

## Author

**Shafaa Shawqi Ali**

Microbiologist and Bioinformatics Researcher

ORCID: **0009-0000-5265-0652**

---

## License
The analysis scripts in this repository are licensed under the MIT License.

The original research data, processed datasets, tables, annotations, and other supporting research materials provided in this repository are licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) License.

Third-party data and materials are not covered by these licenses. In particular, genome assemblies obtained from the NCBI Assembly database remain subject to their original terms and conditions.

See LICENSE for the MIT License and LICENSE-DATA for the CC BY 4.0 License.
