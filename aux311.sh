#!/bin/bash
#
export QEMU_AUDIO_DRV=none

/home/rhoshino/virt/qemu-8.2.0/build/qemu-system-m68k \
        -m 128 -M q800 -bios Quadra800.rom \
        -display vnc=:1 -g 1152x870x8 \
	-rtc base=localtime \
        -serial mon:stdio \
        -net nic -net user,hostfwd=tcp::23002-:23,hostfwd=tcp::21002-:21 \
        -drive file=pram-aux.img,format=raw,if=mtd \
        -device scsi-hd,scsi-id=6,drive=hd0 \
        -drive file=AUX3.img,media=disk,format=raw,if=none,id=hd0 \
	-device scsi-cd,scsi-id=5,drive=cd5 \
	-drive file=/mnt/nettmp/software/macos/iso/destination_internet.iso,media=cdrom,format=raw,if=none,id=cd5 \
	-device scsi-cd,scsi-id=3,drive=cd0 \
	-drive file=archive.hfs,media=cdrom,format=raw,if=none,id=cd0 
