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
# 1. remove any dangling symlinks so restore treats them as missing.
#    The package links sit four levels down
#    (renv/library/macos/R-4.4/aarch64-apple-darwin20/<pkg>), so -maxdepth
#    must be at least 4. Too shallow and this silently matches nothing,
#    restore then sees the dangling links as "installed" and skips them.
find renv/library -maxdepth 4 -type l ! -exec test -e {} \; -delete
# 2. reinstall from the lockfile (cache is off, so these land as real dirs)
Rscript -e 'options(repos=c(PPM="https://packagemanager.posit.co/cran/latest")); renv::restore(prompt=FALSE)'
# 3. materialize anything still linked
Rscript -e 'renv::isolate()'
# verify zero symlinks remain:
find renv/library -maxdepth 4 -type l | wc -l   # want 0
```

Sanity-check step 1 before trusting it: print the count first
(`find renv/library -maxdepth 4 -type l ! -exec test -e {} \; -print | wc -l`).
A zero here when `Rscript` cannot load packages means the depth is wrong, not
that the library is healthy.

**System libraries** some packages need to build from source on macOS.

**gfortran is required, not optional.** A cold restore builds RcppArmadillo,
lme4, Matrix, TMB, mgcv, nlme and fracdiff from source, and all of them link
against Fortran. Without it the link dies with `ld: library 'gfortran' not
found` and renv aborts the entire staged install, so nothing at all lands in
the library. Install the official R toolchain build, which unpacks to
`/opt/gfortran`, the exact path R's `Makeconf` hardcodes in `FLIBS`:

```sh
curl -LO https://mac.r-project.org/tools/gfortran-12.2-universal.pkg
sudo installer -pkg gfortran-12.2-universal.pkg -target /
```

Homebrew's `gcc` also ships gfortran but installs it under the Homebrew
prefix, so R still cannot find it without an `FLIBS` override in
`~/.R/Makevars`. Prefer the official installer.

Install with Homebrew if a different source build fails: `fribidi harfbuzz
freetype` (for textshaping/systemfonts/svglite), and GDAL/GEOS/PROJ/udunits
for `sf`/`tigris`.

**Binaries cannot replace a compiler here.** It is tempting to dodge source
builds with a binary-only repo, but that does not work for this project:

- The PPM `latest` URL publishes no arm64 macOS binary path for R 4.4, so
  every package falls back to source anyway.
- CRAN's arm64 repo carries only the *current* version of each package, while
  the lockfile pins exact older ones. 32 of the 128 locked packages differ
  from the published binary, so renv builds those from source regardless.
- `pkgType = "binary"` makes matters worse: renv then demands a binary of
  renv itself, which the arm64 repo does not carry, and restore aborts during
  retrieval before installing anything.
- `install.packages.compile.from.source = "never"` is honored by
  `install.packages()` but ignored by renv's own install path, so it does not
  prevent the compile either.

Relaxing the pins to the binary versions would avoid compiling, but it shifts
lme4, Matrix, mgcv, MASS and 28 others, which can move the golden values the
tests assert. Install gfortran instead.

## Rendering outputs

Steps 01-02 rebuild the multi-GB PUF cache from raw CSVs and are slow. Steps
03-08 read the frozen `data/cache/puf_classified.rds` and produce every
reporting artifact (abstract, tables, figures, manuscript). None of 03-08 write
the cache, so re-render with just those. `00_run_all.R` runs the full pipeline.

## Writing

Never use the em dash in any written output (prose, comments, commit messages,
manuscript). Use commas, parentheses, or separate sentences instead.
