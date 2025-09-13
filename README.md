# Yocto Build for SPIRIT Phone

This repo aims to act as a reference build setup for the
[SPIRIT phone](https://github.com/V3lectronics/SPIRIT).
It uses [`kas`](https://github.com/siemens/kas) to simplify setup and building.

## Requirements
- Linux host (or WSL2 on Windows / Docker Desktop on macOS)
- Docker or Podman installed
- ~50–100 GB free disk space, a moderate amount of CPU/RAM (first build is heavy!)
- [`kas`](https://kas.readthedocs.io/en/latest/userguide/getting-started.html)

## Build

Clone this repository, then go **one directory up** before building.
(`kas` will create the actual build directory there and fetch other layers automatically.)

To build run the command:

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


### Troubleshooting

Most errors aren’t scary. If a recipe fails, just clean it and rebuild.

#### Example error:

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

## Flash

To flash the eMMC on the IO Board the
[`rpiboot`](https://github.com/raspberrypi/usbboot?tab=readme-ov-file#troubleshooting)
utility needs to be used to put the eMMC into flash mode.

1. A `EMMC-DISABLE / nRPIBOOT (BCM2712 GPIO 20)` pin must be lowered by connecting a jumper/F-F cable.
1. Connect the device USB-C port to your host.
1. Run [`rpiboot`](https://github.com/raspberrypi/usbboot) to put eMMC into flash mode.
    - To ease up development a [container](./scripts/rpiboot/Dockerfile) has been prepared for this step.
        ```sh
        # build the container
        $ docker build -t rpiboot meta-spirit/scripts/rpiboot

        # run it with --privileged and passing the peripherals. Below is an example correct output
        $ docker run --rm -it --init \
            --privileged \
            --device /dev:/dev \
            rpiboot

        RPIBOOT: build-date 2025/09/13 pkg-version local 466e26dc

        Please fit the EMMC_DISABLE / nRPIBOOT jumper before connecting the power and USB cables to the target device.
        If the device fails to connect then please see https://rpltd.co/rpiboot for debugging tips.

        Waiting for BCM2835/6/7/2711/2712...

        Directory not specified - trying default /usr/share/rpiboot/mass-storage-gadget64/
        Second stage boot server
        File read: mcb.bin
        File read: memsys00.bin
        File read: memsys01.bin
        File read: memsys02.bin
        File read: memsys03.bin
        File read: bootmain
        Loading: /usr/share/rpiboot/mass-storage-gadget64//config.txt
        File read: config.txt
        Loading: /usr/share/rpiboot/mass-storage-gadget64//boot.img
        File read: boot.img
        Second stage boot server done

        # a new device should appear in your lsblk/dmesg. Make sure it's unmounted before proceeding
        $ umount /dev/sdX
        ```
1. Copy the image to the eMMC.
    ```sh
    $ bmaptool copy build/tmp/deploy/images/raspberrypi5/core-image-minimal-raspberrypi5.rootfs.wic.bz2 /dev/sdX
    bmaptool: info: discovered bmap file 'build/tmp/deploy/images/raspberrypi5/core-image-minimal-raspberrypi5.rootfs.wic.bmap'
    bmaptool: info: block map format version 2.0
    bmaptool: info: 43707 blocks of size 4096 (170.7 MiB), mapped 16919 blocks (66.1 MiB or 38.7%)
    bmaptool: info: copying image 'core-image-minimal-raspberrypi5.rootfs.wic.bz2' to block device '/dev/sda' using bmap file 'core-image-minimal-raspberrypi5.rootfs.wic.bmap'
    bmaptool: info: 100% copied
    bmaptool: info: synchronizing '/dev/sda'
    bmaptool: info: copying time: 3.0s, copying speed 22.0 MiB/sec
    ```
1. Remove the jumper from the `EMMC-DISABLE / nRPIBOOT (BCM2712 GPIO 20)`.
1. Power cycle the device.