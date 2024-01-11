#!/bin/bash
qemu-system-hppa -boot order=c -m 512 -machine hppa \
	-nographic \
	-drive file=hpux.img,format=raw \
	-nic user,ipv6=off,model=tulip,id=lan0,hostfwd=tcp:0.0.0.0:23001-:23 \
	-accel tcg,thread=multi \
	-d nochain
