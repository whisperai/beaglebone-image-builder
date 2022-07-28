# Beaglebone Image Creation Repo
This is a fork of https://github.com/RobertCNelson/omap-image-builder.

## Creating a BBB Debian image
This is done in 2 steps. Note that the `configs` folder determines all dependencies that
are installed. Thus if you want to change the dependencies, you should create a new conf file.

This tutorial is mostly taken from this [BB forum post](https://forum.beagleboard.org/t/creating-a-custom-bbb-debian-image-non-interactively/31368/2),
which outlines how Robert Nelson (the chief beaglebone community guy) builds things.

1. Build a generic image
```
./RootStock-NG.sh -c configs/bb.org-debian-bullseye-minimal-v5.10-ti-armhf.conf
```
This will generate: debian-11.2-minimal-armhf-2022-01-01.tar.xz

1. Convert Generic to BeagleBone specific
```
sudo ./tools/setup_sdcard.sh --img-4gb am335x-debian-11.2-iot-armhf-2022-01-01 \
  --dtb beaglebone --distro-bootloader --enable-cape-universal \
  --enable-uboot-disable-pru --enable-bypass-bootup-scripts
```
which will result in `am335x-debian-11.2-minimal-armhf-2022-01-01-2gb.img.xz`. NOTE: this will
create an SD card image that runs on the beaglebone (instead of flashing the emmc). To create a
flasher SD card, use `--bbgg-flasher` (or replace bbgg with your beaglebone version).
