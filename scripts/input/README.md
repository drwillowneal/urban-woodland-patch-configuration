# Input data

The pipeline reads the files below. They are not stored in the repository, because several are large or licensed. Download each one and place it at the path shown, inside this folder.

To keep the data somewhere else, copy `.Renviron.example` (in the project root) to `.Renviron` and set `URBAN_WOODLAND_INPUT` to that folder. The layout inside it must be the same as below.

| Path inside this folder | What it is | Source |
|---|---|---|
| `built_up_areas/BUA_2022_GB_8703850870315979820.gpkg` | ONS Built Up Area boundaries (December 2022), Great Britain; a GeoPackage with one layer, `BUA_2022_GB` | ONS Open Geography Portal, [Built Up Areas (December 2022) Boundaries GB BGG](https://geoportal.statistics.gov.uk/datasets/ons::built-up-areas-december-2022-boundaries-gb-bgg/about) |
| `UKCEH_Land_Cover_2023/gblcm2023_10m.tif` | Land Cover Map 2023, 10 m classified pixels, GB (about 2.3 GB) | Morton et al. (2024), NERC EDS Environmental Information Data Centre, https://doi.org/10.5285/7727ce7d-531e-4d77-b756-5cc59ff016bd (registration and licence required) |
| `National_Forest_Inventory/National_Forest_Inventory_GB_2024.geojson` | National Forest Inventory GB 2024 (about 4 GB) | Forestry Commission (2025), Open Government Licence v3.0, https://environment.data.gov.uk/dataset/0dbabff6-588e-44b3-a316-6353c4e47025 |
| `LSOA_codes.csv` | Lookup from 2021 LSOAs to 2022 Built Up Areas, local authorities and regions (columns `LSOA21CD`, `BUA22CD`, `RGN22NM`, ...) | ONS, [LSOA (2021) to BUA to LAD to Region (December 2022) Best Fit Lookup in EW (V2)](https://www.data.gov.uk/dataset/lsoa-2021-to-bua-to-lad-to-region-december-2022-best-fit-lookup-in-ew-v2), CSV download |
| `census2021.csv` | Census 2021 usual resident population by Built Up Area (columns `Country code`, `Region`, `BUA code`, `BUA name`, `BUA size classification`, `Counts`), saved as CSV | ONS, [Towns and cities, characteristics of built-up areas, England and Wales: Census 2021](https://www.ons.gov.uk/peoplepopulationandcommunity/housing/datasets/townsandcitiescharacteristicsofbuiltupareasenglandandwalescensus2021) |
| `European_butterflies_movement_distances.xlsx` | Movement distances of European butterflies (sheets `Species codes`, `Movement distances`, `Sources`) | Hülber (2024), Phaidra, University of Vienna, https://phaidra.univie.ac.at/detail/o:2044834 |

The pages for the built-up areas boundaries and the census table do not list their download formats or file names, so confirm the exact version and table you downloaded, and add the download date for each ONS item.

Two further inputs are downloaded by the code itself when it runs, so they need no action: the ONS England boundary and the ONS Major Towns and Cities boundaries (both in `02_Resistance_Surface.Rmd`).

`scripts/region_name_overrides.csv` is hand-written analysis configuration and is kept in the repository.
