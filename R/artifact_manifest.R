# =============================================================================
# artifact_manifest.R
#
# SHA-256 artifact tracking for pipeline reproducibility.
# Every artifact written by the pipeline is recorded in a JSON manifest
# with its hash, timestamp, and provenance metadata.
#
# Functions:
#   artifact_write()   — save RDS + record hash in manifest
#   artifact_read()    — load RDS + optionally verify hash
#   artifact_csv()     — write CSV + record hash in manifest
#   manifest_verify()  — check all recorded artifacts still match
#   manifest_summary() — print human-readable manifest report
#
# Pattern from Stanford opencap provenance tracking.
#
# Authors: Tyler Muffly, MD
# =============================================================================

#' @noRd
manifest_path <- function(cache_dir) {
  file.path(cache_dir, ".artifact_manifest.json")
}

#' @noRd
read_manifest <- function(cache_dir) {
  mpath <- manifest_path(cache_dir)
  if (file.exists(mpath)) {
    jsonlite::fromJSON(mpath, simplifyDataFrame = FALSE)
  } else {
    list()
  }
}

#' @noRd
write_manifest <- function(manifest, cache_dir) {
  mpath <- manifest_path(cache_dir)
  dir.create(dirname(mpath), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(
    manifest,
    path       = mpath,
    pretty     = TRUE,
    auto_unbox = TRUE
  )
}

#' @noRd
compute_file_hash <- function(file_path) {
  digest::digest(file = file_path, algo = "sha256")
}

#' Write an R object as RDS and record its hash in the manifest
#'
#' @param object The R object to serialize.
#' @param artifact_name Character. Logical name for the artifact.
#' @param file_path Character. Destination .rds file path.
#' @param phase Character. Pipeline phase that produced this artifact.
#' @param phase_script Character. Script file that produced this artifact.
#' @param cache_dir Character. Directory containing the manifest JSON.
#' @param verbose Logical. Print progress messages.
#' @return Invisible NULL.
artifact_write <- function(
    object,
    artifact_name,
    file_path,
    phase        = NA_character_,
    phase_script = NA_character_,
    cache_dir    = "data/cache",
    verbose      = TRUE
) {
  dir.create(dirname(file_path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(object, file = file_path)

  file_hash <- compute_file_hash(file_path)

  manifest <- read_manifest(cache_dir)
  manifest[[artifact_name]] <- list(
    file_path    = file_path,
    sha256       = file_hash,
    phase        = phase,
    phase_script = phase_script,
    timestamp    = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"),
    size_bytes   = file.info(file_path)$size
  )
  write_manifest(manifest, cache_dir)

  if (isTRUE(verbose)) {
    message(glue::glue(
      "[artifact_write] {artifact_name} -> {file_path} ",
      "(SHA-256: {substr(file_hash, 1, 12)}...)"
    ))
  }
  invisible(NULL)
}

#' Read an RDS artifact and optionally verify its hash
#'
#' @param artifact_name Character. Logical name for the artifact.
#' @param file_path Character. Path to the .rds file.
#' @param cache_dir Character. Directory containing the manifest JSON.
#' @param verify_hash Logical. If TRUE, check the file hash against manifest.
#' @param verbose Logical. Print progress messages.
#' @return The deserialized R object.
artifact_read <- function(
    artifact_name,
    file_path,
    cache_dir   = "data/cache",
    verify_hash = FALSE,
    verbose     = TRUE
) {
  assertthat::assert_that(
    file.exists(file_path),
    msg = glue::glue("Artifact not found: {file_path}")
  )

  if (isTRUE(verify_hash)) {
    manifest <- read_manifest(cache_dir)
    if (!is.null(manifest[[artifact_name]])) {
      recorded_hash <- manifest[[artifact_name]]$sha256
      current_hash  <- compute_file_hash(file_path)
      if (!identical(recorded_hash, current_hash)) {
        warning(glue::glue(
          "[artifact_read] Hash mismatch for '{artifact_name}': ",
          "recorded={substr(recorded_hash, 1, 12)}... ",
          "current={substr(current_hash, 1, 12)}... ",
          "The artifact may have been modified outside the pipeline."
        ))
      } else if (isTRUE(verbose)) {
        message(glue::glue(
          "[artifact_read] {artifact_name}: hash verified OK"
        ))
      }
    } else if (isTRUE(verbose)) {
      message(glue::glue(
        "[artifact_read] {artifact_name}: not in manifest (skipping verify)"
      ))
    }
  }

  readRDS(file_path)
}

#' Write a CSV artifact and record its hash in the manifest
#'
#' @param tbl Data frame or tibble to write.
#' @param artifact_name Character. Logical name for the artifact.
#' @param file_path Character. Destination .csv file path.
#' @param phase Character. Pipeline phase.
#' @param phase_script Character. Script file.
#' @param cache_dir Character. Directory containing the manifest JSON.
#' @param verbose Logical.
#' @return Invisible NULL.
artifact_csv <- function(
    tbl,
    artifact_name,
    file_path,
    phase        = NA_character_,
    phase_script = NA_character_,
    cache_dir    = "data/cache",
    verbose      = TRUE
) {
  dir.create(dirname(file_path), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(tbl, file_path)

  file_hash <- compute_file_hash(file_path)

  manifest <- read_manifest(cache_dir)
  manifest[[artifact_name]] <- list(
    file_path    = file_path,
    sha256       = file_hash,
    phase        = phase,
    phase_script = phase_script,
    timestamp    = format(Sys.time(), "%Y-%m-%dT%H:%M:%S"),
    size_bytes   = file.info(file_path)$size
  )
  write_manifest(manifest, cache_dir)

  if (isTRUE(verbose)) {
    message(glue::glue(
      "[artifact_csv] {artifact_name} -> {file_path} ",
      "({nrow(tbl)} rows, SHA-256: {substr(file_hash, 1, 12)}...)"
    ))
  }
  invisible(NULL)
}

#' Verify all manifest artifacts still match their recorded hashes
#'
#' @param cache_dir Character. Directory containing the manifest JSON.
#' @param verbose Logical.
#' @return Invisible TRUE if all pass, stops on mismatch.
manifest_verify <- function(cache_dir = "data/cache", verbose = TRUE) {
  manifest <- read_manifest(cache_dir)
  if (length(manifest) == 0L) {
    if (isTRUE(verbose)) message("[manifest_verify] No artifacts recorded.")
    return(invisible(TRUE))
  }

  n_checked <- 0L
  n_missing <- 0L
  n_failed  <- 0L

  for (name in names(manifest)) {
    entry <- manifest[[name]]
    fpath <- entry$file_path
    if (!file.exists(fpath)) {
      n_missing <- n_missing + 1L
      warning(glue::glue("[manifest_verify] MISSING: {name} ({fpath})"))
      next
    }
    current_hash <- compute_file_hash(fpath)
    if (!identical(current_hash, entry$sha256)) {
      n_failed <- n_failed + 1L
      warning(glue::glue(
        "[manifest_verify] MISMATCH: {name} ",
        "(recorded={substr(entry$sha256, 1, 12)}..., ",
        "current={substr(current_hash, 1, 12)}...)"
      ))
    }
    n_checked <- n_checked + 1L
  }

  if (isTRUE(verbose)) {
    message(glue::glue(
      "[manifest_verify] {n_checked} checked, ",
      "{n_missing} missing, {n_failed} mismatched"
    ))
  }

  if (n_failed > 0L) {
    stop(glue::glue(
      "Artifact verification failed: {n_failed} hash mismatch(es). ",
      "Re-run the pipeline to regenerate stale artifacts."
    ))
  }
  invisible(TRUE)
}

#' Print a human-readable summary of the artifact manifest
#'
#' @param cache_dir Character. Directory containing the manifest JSON.
#' @param verbose Logical.
#' @return Invisible NULL.
manifest_summary <- function(cache_dir = "data/cache", verbose = TRUE) {
  manifest <- read_manifest(cache_dir)
  if (length(manifest) == 0L) {
    if (isTRUE(verbose)) message("[manifest_summary] No artifacts recorded.")
    return(invisible(NULL))
  }

  if (isTRUE(verbose)) {
    message(glue::glue(
      "\n[manifest_summary] {length(manifest)} artifact(s) in manifest:"
    ))
    for (name in names(manifest)) {
      entry <- manifest[[name]]
      size_kb <- round(entry$size_bytes / 1024, 1)
      message(glue::glue(
        "  {name}: {size_kb} KB | {entry$phase} | {entry$timestamp}"
      ))
    }
  }
  invisible(NULL)
}
