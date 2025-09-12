# Yocto Build for SPIRIT Phone

This repo aims to act as a reference build setup for the
[SPIRIT phone](https://github.com/V3lectronics/SPIRIT).
It uses [`kas`](https://github.com/siemens/kas) to simplify setup and building.

## Requirements
- Linux host (or WSL2 on Windows / Docker Desktop on macOS)
- Docker or Podman installed
- ~50–100 GB free disk space, a moderate amount of CPU/RAM (first build is heavy!)
- [`kas`](https://kas.readthedocs.io/en/latest/userguide/getting-started.html)

## Quickstart

Clone this repository, then go **one directory up** before building.
(`kas` will create the actual build directory there and fetch other layers automatically.)

Build the image:

```sh
kas-container build meta-spirit/kas.yml
```

The first build can take hours on a personal computer/laptop.

To limit CPU usage (example: 4 cores):

```sh
export BB_NUMBER_THREADS=4
export PARALLEL_MAKE="-j4"
kas-container build meta-spirit/kas.yml
```

## Troubleshooting

Most errors aren’t scary. If a recipe fails, just clean it and rebuild.

### Example error:

```log
ERROR: Task (.../gcc_13.4.bb:do_compile) failed with exit code '1'
```

Fix:

```sh
# open a shell inside the build container
kas-container shell meta-spirit/kas.yml

# clean the recipe
bitbake -c cleanall gcc

# exit and rebuild
exit
kas-container build meta-spirit/kas.yml
```

When in doubt refer to
[Yocto Project Documentation](https://docs.yoctoproject.org/5.0.12/singleindex.html)
or open an issue.
