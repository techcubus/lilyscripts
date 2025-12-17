#!/bin/sh
QEMU_ROOT="/home/rhoshino/git/qemu-screamer/build/"
DRIVEIMG_ROOT="/media/rhoshino/Windows/Users/Shira/Documents"
export QEMU_AUDIO_DRV=pa

cd ${QEMU_ROOT}

if $(true); then
	$NET_OPTS="-netdev user,id=network0 -device sungem,netdev=network0"
fi
if $(false) ; then
	$NET_OPTS="-netdev tap,id=tap0,ifname=tap0,script=no,downscript=no -device tap0,sungem,netdev=tap0"
fi


${QEMU_ROOT}/qemu-system-ppc \
	-display gtk \
	-boot c \
	-M mac99,via=pmu \
	-m 896 \
	-cpu g4 \
	-L /home/rhoshino/git/qemu-screamer/pc-bios/ \
	-d unimp,guest_errors \
	-accel tcg,tb-size=2048 \
	-prom-env "boot-args=-v" \
	-prom-env "vga-ndrv?=true" \
	-device VGA,edid=on \
	-g 1280x720x32 \
	-rtc base=localtime \
	-drive file=${DRIVEIMG_ROOT}/MacOS9.2.img,format=qcow2,media=disk \
	-drive file="${DRIVEIMG_ROOT}/HD1 BlueSCSI v2 PicoW Setup.hda",format=raw,media=cdrom \
	-drive file=${DRIVEIMG_ROOT}/SoftwareLibrary.img,format=raw,media=disk \
	-drive file=${DRIVEIMG_ROOT}/destination_internet.iso,format=raw,media=cdrom \
	${NET_OPTS}
