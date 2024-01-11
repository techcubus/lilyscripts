#!/bin/bash
VMDIR="/home/rhoshino/virt/sparc"

cd ${VMDIR}

qemu-system-sparc \
	-m 256 -M SS-5  \
	-nographic \
	-drive file=dasd/sparc_sol7.qcow2,bus=0,unit=0,media=disk \
	-nic user,hostfwd=tcp:0.0.0.0:23000-10.0.2.10:23 -nic user,hostfwd=tcp:0.0.0.0:26000-10.0.2.10:6000,hostfwd=udp:0.0.0.0:26000-10.0.2.10:6000
