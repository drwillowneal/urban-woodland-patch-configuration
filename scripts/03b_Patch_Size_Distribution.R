# Per-region woodland patch size distribution, computed directly from
# connected components of the woodland raster (terra::patches()) rather
# than from the MPG graph. Patch identity and area do not depend on the
# resistance surface or on any movement threshold, so this skips graph
# construction and is much cheaper than the national ECS run. It also
# keeps patch-level detail that the ECS run discards.
#
# Run after the national loop in 03_National_ECS.Rmd, whose results it
# reads. Writes `10_patch_size_distribution.csv` to the checkpoint folder.
# The `results_fig1_structure_revised` and `results_descriptives` chunks
# (03_National_ECS.Rmd and 04_Results_Figures.Rmd) join its `awm_patch_ha`
# and `largest_patch_ha` columns onto the national results for Figure 1
# and Table 1.

source(here::here("scripts", "00_setup.R"))
suppressMessages({ library(sf); library(terra); library(dplyr) })

# London's woodland raster is large enough to exceed terra's default
# memory fraction (std::bad_alloc). Raising memfrac and giving terra an
# explicit scratch directory lets intermediate rasters spill to disk
# instead of failing.
tmpdir <- file.path(tempdir(), "terra_national_patches")
dir.create(tmpdir, showWarnings = FALSE, recursive = TRUE)
terraOptions(memfrac = 0.75, tempdir = tmpdir, progress = 0)

urban_regions_named <- readRDS(file.path(checkpoint_dir, "07b_urban_regions_named.rds"))
nfi_urban <- readRDS(file.path(checkpoint_dir, "nfi_urban_regions.rds"))
out_path <- file.path(checkpoint_dir, "10_patch_size_distribution.csv")

# Patch areas only (no MPG or least-cost paths). terra::patches() gives
# the connected components of the woodland mask directly, which is all
# the patch-size distribution needs.
patch_stats <- function(region_name) {
  region <- urban_regions_named |> filter(bua_name == region_name)
  bbox <- st_bbox(region); rv <- vect(region)
  lcm_zoom <- rast(lcm_file) |> crop(vect(st_as_sfc(bbox)))
  nfi_zoom <- st_crop(nfi_urban, bbox) |> st_collection_extract("POLYGON")
  nfi_r <- rasterize(vect(nfi_zoom), lcm_zoom[[1]], field = 1, background = 0)
  classified <- lcm_zoom[[1]]
  classified[(lcm_zoom[[1]] %in% c(1, 2)) | (nfi_r > 0)] <- 1
  bm <- rasterize(rv, classified, field = 1, background = 0)
  wood <- (classified == 1) & (bm == 1)
  wood[wood == 0] <- NA
  wood <- mask(wood, rv) |> trim()

  # directions = 8 to match grainscape's own patch identification
  pt <- patches(wood, directions = 8, zeroAsNA = TRUE)
  fr <- as.data.frame(freq(pt))
  if (nrow(fr) == 0) return(NULL)
  cell_ha <- prod(res(pt)) / 10000
  a <- fr$count * cell_ha                      # patch areas, ha

  data.frame(
    region        = region_name,
    n_patches_raster = length(a),
    total_ha      = sum(a),
    mean_patch_ha = mean(a),
    median_patch_ha = median(a),
    # Area-weighted mean patch size == ECS at threshold 0:
    # sum(a^2)/sum(a). The patch size experienced by a randomly
    # chosen unit of woodland, rather than by a randomly chosen patch.
    awm_patch_ha  = sum(a^2) / sum(a),
    largest_patch_ha = max(a),
    # Share of the woodland resource (area) that sits in small patches, as
    # distinct from the share of the patch count that is small.
    pct_area_under_0p5 = 100 * sum(a[a < 0.5]) / sum(a),
    pct_area_under_1   = 100 * sum(a[a < 1])   / sum(a),
    pct_area_under_5   = 100 * sum(a[a < 5])   / sum(a),
    pct_count_under_1  = 100 * mean(a < 1),
    error = NA
  )
}

nat <- read.csv(file.path(checkpoint_dir, "08_national_ecs_results.csv"), stringsAsFactors = FALSE)
regions <- nat |> filter(is.na(error)) |> pull(region)

if (file.exists(out_path)) {
  prior <- read.csv(out_path, stringsAsFactors = FALSE)
  acc <- list(prior); done <- prior$region
  cat("Resuming:", nrow(prior), "done.\n")
} else { acc <- list(); done <- character(0) }
todo <- setdiff(regions, done)
cat("To process:", length(todo), "\n\n")

for (i in seq_along(todo)) {
  rn <- todo[i]
  res <- tryCatch(patch_stats(rn), error = function(e)
    data.frame(region = rn, n_patches_raster = NA, total_ha = NA, mean_patch_ha = NA,
               median_patch_ha = NA, awm_patch_ha = NA, largest_patch_ha = NA,
               pct_area_under_0p5 = NA, pct_area_under_1 = NA, pct_area_under_5 = NA,
               pct_count_under_1 = NA, error = conditionMessage(e)))
  if (!is.null(res)) acc[[length(acc) + 1]] <- res
  if (i %% 100 == 0 || i == length(todo)) {
    write.csv(bind_rows(acc), out_path, row.names = FALSE)
    cat(sprintf("[%d/%d]\n", i, length(todo)))
  }
}
write.csv(bind_rows(acc), out_path, row.names = FALSE)
cat("\n=== PATCH SIZE DISTRIBUTION COMPLETE ===\n")
