# Patch configuration shapes functional connectivity in England’s urban woodlands

Analysis code for the paper of the same title. It assesses the functional connectivity of urban woodland for butterflies across English urban regions. It delineates urban regions from ONS Built Up Areas, builds a resistance surface from the Land Cover Map and National Forest Inventory, computes Expected Cluster Size (ECS) for every region at three movement thresholds (59, 99 and 512 m), and models how connectivity relates to woodland amount, fragmentation and patch spacing.

## Data

The input data are not stored in this repository, because several files are large or licensed.

| Input | Source |
|---|---|
| Built Up Area boundaries (December 2022) | ONS Open Geography Portal, [Built Up Areas (December 2022) Boundaries GB BGG](https://geoportal.statistics.gov.uk/datasets/ons::built-up-areas-december-2022-boundaries-gb-bgg/about) |
| Land Cover Map 2023, 10 m classified pixels, GB | Morton et al. (2024), NERC EDS Environmental Information Data Centre, [doi:10.5285/7727ce7d-531e-4d77-b756-5cc59ff016bd](https://doi.org/10.5285/7727ce7d-531e-4d77-b756-5cc59ff016bd) (registration and licence required) |
| National Forest Inventory GB 2024 | Forestry Commission (2025), Open Government Licence v3.0, [dataset page](https://environment.data.gov.uk/dataset/0dbabff6-588e-44b3-a316-6353c4e47025) |
| LSOA (2021) to Built Up Area, local authority and region lookup | ONS, [LSOA (2021) to BUA to LAD to Region (December 2022) Best Fit Lookup in EW (V2)](https://www.data.gov.uk/dataset/lsoa-2021-to-bua-to-lad-to-region-december-2022-best-fit-lookup-in-ew-v2) |
| Census 2021 population by Built Up Area | ONS, [Towns and cities, characteristics of built-up areas, England and Wales: Census 2021](https://www.ons.gov.uk/peoplepopulationandcommunity/housing/datasets/townsandcitiescharacteristicsofbuiltupareasenglandandwalescensus2021) |
| Movement distances of European butterflies | Hülber (2024), [Phaidra, University of Vienna](https://phaidra.univie.ac.at/detail/o:2044834) |

[`scripts/input/README.md`](scripts/input/README.md) gives the exact file names and the folder layout the code expects.

**Pre-computed results.** The national run takes several hours. The results it produces (national ECS, the threshold sweep, patch spacing and patch sizes, and the sensitivity runs) are deposited in the Open University's ORDO repository: [doi:10.21954/ou.rd.34925253](https://doi.org/10.21954/ou.rd.34925253). The deposit's README explains where to place the files so the notebooks skip the completed work.

## Requirements

R 4.5.0 (RStudio recommended; open `urban-woodland-patch-configuration.Rproj` so that paths resolve from the project root) and these packages:

| Package | Version | Package | Version |
|---|---|---|---|
| dplyr | 1.1.4 | officer | 0.7.6 |
| ggplot2 | 4.0.1 | patchwork | 1.3.2 |
| ggrepel | 0.9.6 | raster | 3.6.32 |
| ggridges | 0.5.6 | readr | 2.1.5 |
| grainscape | 0.5.0 | readxl | 1.4.5 |
| gratia | 0.11.1 | scales | 1.4.0 |
| here | 1.0.2 | sf | 1.0.21 |
| igraph | 2.1.4 | terra | 1.8.60 |
| knitr | 1.50 | tibble | 3.2.1 |
| MASS | 7.3.65 | tidyr | 1.3.1 |
| mgcv | 1.9.1 | tidyverse | 2.0.0 |

## Setting up

By default the code reads the input data from `scripts/input/` and writes saved intermediate results to `scripts/checkpoints/` (about 2 GB after a full run). To use other folders, copy `.Renviron.example` to `.Renviron` in the project root and set `URBAN_WOODLAND_INPUT` and `URBAN_WOODLAND_CHECKPOINTS`. No other path needs editing.

## Running the analysis

Open each notebook in `scripts/` in this order and choose Run All. Every notebook starts by sourcing `00_setup.R`.

| Step | Notebook | What it does |
|---|---|---|
| 1 | `01a_Prepare_BUA_Groups.Rmd` | Groups, closes and splits ONS Built Up Areas into urban regions |
| 2 | `01b_Analyse_Urban_Regions.Rmd` | Names and checks the regions; clips the National Forest Inventory to them |
| 3 | `02_Resistance_Surface.Rmd` | Builds the national resistance surface and fetches the ONS Major Towns and Cities boundaries |
| 4 | `02b_Movement_Thresholds.Rmd` | Derives the movement thresholds from the butterfly movement-distance data |
| 5 | `03_National_ECS.Rmd` | National ECS run for every region (several hours), threshold sweep, models, sensitivity analyses |
| 6 | `03b_Patch_Size_Distribution.R` | Patch sizes per region (reads the results of step 5) |
| 7 | `03_National_ECS.Rmd` again | Resumes from the saved results, so the chunks that need patch sizes now complete |
| 8 | `04_Results_Figures.Rmd` | Tables and figures |

The long loops in `03` save their results as they go and skip anything already done, so an interrupted run can be restarted. With the pre-computed results in place, steps 1 to 3 are still needed (they rebuild the region geometries and woodland layers, which take a few hours), but step 5 then finishes in minutes. The first lines of `03_National_ECS.Rmd` and `04_Results_Figures.Rmd` list which chunk produces each table and figure, and the output file name.

## Outputs

Figures and tables are written to `figures/`.

## Folder structure

| Folder | Contents |
|---|---|
| `scripts/` | The notebooks and `00_setup.R` |
| `scripts/input/` | Input data (downloaded by the user; see its README) |
| `scripts/sensitivity_analysis/` | Saved results of the sensitivity runs that `03` reads |
| `data/movement_distances/` | Species movement-distance tables produced by `02b` |
| `figures/` | Figures and tables written by the notebooks (created when the code runs) |

## Citation

If you use this code, please cite the paper and the results deposit ([doi:10.21954/ou.rd.34925253](https://doi.org/10.21954/ou.rd.34925253)). Publication details for the paper will be added here when available.

## Licence

The code is released under the MIT licence (see `LICENSE`). The input data are covered by their own licences; see `scripts/input/README.md`.
