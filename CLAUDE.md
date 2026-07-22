# CLAUDE.md

Project guidance for Claude Code working in this repository.

## Environment: renv library keeps disappearing (and the permanent fix)

**Symptom.** Every so often the whole project library evaporates: `Rscript`
fails with `there is no package called 'config'` (or dplyr, rmarkdown, etc.),
and `renv::status()` reports dozens of "broken symlinks into the cache."

**Root cause.** By default renv does not store packages in
`renv/library/` directly. It stores one shared copy in a global cache under
`~/Library/Caches/org.R-project.R/R/renv/cache/` and fills `renv/library/`
with **symlinks** pointing into that cache. When the global cache gets wiped,
every symlink dangles at once and the library is effectively gone. On this Mac
the cache was being wiped by a background load storm / CleanMyMac (see the
`mac-restart-windowserver` memory note), so this recurred repeatedly.

**Permanent fix (already applied).** Disable the cache for this project so
packages are copied as **real files** into `renv/library/`. There is nothing
to dangle, so a cache wipe can no longer touch the project:

```r
renv::settings$use.cache(FALSE)   # persists to renv/settings.json (tracked in git)
renv::isolate()                   # copy currently-linked packages out of the cache into the library
```

The setting lives in `renv/settings.json`, which **is committed to git**, so the
fix travels with the repo and survives future clones.

**If it happens again anyway** (e.g. a package was added back with the cache on):

```sh
# 1. remove any dangling symlinks so restore treats them as missing
find renv/library -maxdepth 3 -type l ! -exec test -e {} \; -delete
# 2. reinstall from the lockfile (cache is off, so these land as real dirs)
Rscript -e 'options(repos=c(PPM="https://packagemanager.posit.co/cran/latest")); renv::restore(prompt=FALSE)'
# 3. materialize anything still linked
Rscript -e 'renv::isolate()'
# verify zero symlinks remain:
find renv/library -maxdepth 3 -type l | wc -l   # want 0
```

**System libraries** some packages need to build from source on macOS
(install with Homebrew if a source build fails): `fribidi harfbuzz freetype`
(for textshaping/systemfonts/svglite), and GDAL/GEOS/PROJ/udunits for
`sf`/`tigris`. Prefer PPM binaries (the `packagemanager.posit.co` repo above)
to avoid compilation entirely.

## Rendering outputs

Steps 01-02 rebuild the multi-GB PUF cache from raw CSVs and are slow. Steps
03-08 read the frozen `data/cache/puf_classified.rds` and produce every
reporting artifact (abstract, tables, figures, manuscript). None of 03-08 write
the cache, so re-render with just those. `00_run_all.R` runs the full pipeline.

## Writing

Never use the em dash in any written output (prose, comments, commit messages,
manuscript). Use commas, parentheses, or separate sentences instead.
