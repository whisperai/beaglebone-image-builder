# Beaglebone Image Creation Repo
This is a fork of https://github.com/RobertCNelson/omap-image-builder.

## Flashing an SD card with a Whisper BeagleBone image
Download [balenaEtcher](https://www.balena.io/etcher) to flash the SD card, and connect a micro SD card to your computer.

1. Download an image from [CircleCI](https://app.circleci.com/pipelines/github/whisperai/beaglebone-image-builder) (going into a build step, and download
   the `.img.xz` file).

1. Open balenaEtcher, select the downloaded file, the connected SD card, and click `Flash`.

1. Power the BeagleBone off, insert the SD card, and re-apply power.

1. The lights should light on one-by-one, stay all on for a second, and then a heartbeat pattern should begin. The system will take
   1-2 minutes to fully boot + bring up the ssh server. After waiting 2 minutes, you can run `ssh debian@beaglebone.local` to ssh into
   the device (password should be `whisperai`).

If you're developing a lot of images, it may get annoying to keep updating `~/.ssh/known_hosts`. you can add
```
Host beaglebone.local
	StrictHostKeyChecking no
	UserKnownHostsFile=/dev/null
```
to `/etc/ssh/ssh_config` to make `beaglebone.local` always trusted (note tabs instead of spaces here are necessary).

## How to add functionality to an image
There are two places that you easily make modifications to the build process. 

1. In `./configs`, you can edit the packages that are installed into the linux image on the beaglebone in `deb_include`
   (which are installed via `apt-get`). You can also add python packages to `python3_pkgs`, although if you're adding
   python packages you probably should be adding them in `./custom_python/setup.py` (unless they're not used in `custom_python`).

1. In a config file, note that there are 
```
chroot_before_hook="scripts/whisper_chroot.sh"
chroot_after_hook=""
```
you can add to the existing scripts, or create new ones to do custom things for images.


## How BeagleBone images are created
This tutorial is mostly taken from this [BB forum post](https://forum.beagleboard.org/t/creating-a-custom-bbb-debian-image-non-interactively/31368/2),
which outlines how Robert Nelson (the chief beaglebone community dev) builds things. NOTE: this MUST be done on a linux machine.

1. Build a generic image
```
./RootStock-NG.sh -c configs/whisper-speedwagon-flex-test.conf
```
This will generate: debian-11.2-iot-armhf-{current-date}.tar.xz

1. cd into that image (will show up in `./deploy`)

1. Convert Generic to BeagleBone specific
```
sudo ./tools/setup_sdcard.sh --img-4gb am335x-debian-11.2-iot-armhf-2022-01-01 \
  --dtb beaglebone --distro-bootloader --enable-cape-universal \
  --enable-uboot-disable-pru --enable-bypass-bootup-scripts
```
which will result in `am335x-debian-11.2-minimal-armhf-{current-date}-4gb.img.xz`. NOTE: this will
create an SD card image that runs on the beaglebone (instead of flashing the emmc). To create a
flasher SD card, use `--bbgg-flasher` (or replace bbgg with your beaglebone version).
