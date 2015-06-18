#!/bin/sh

export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

echo "AUTOBSD"

echo " "

echo "Pressione CTRL+C para cancelar em ate 5 segundos..."
sleep 5

disco="$1"
tamanho_system=$2
tamanho_swap=$3

gpart destroy -F ${disco}

gpart create -s GPT ${disco}
gpart add -s 512k -a 4k -t freebsd-boot -l "boot" ${disco}
gpart add -s ${tamanho_system}M -t freebsd-ufs -l "system" ${disco}
gpart add -s ${tamanho_swap}M -t freebsd-swap -l "swap" ${disco}

gpart bootcode -b /boot/pmbr -p /boot/gptboot -i 1 ${disco}

newfs -j /dev/${disco}p2

mount /dev/${disco}p2 /mnt

exit 0

rsync -av --exclude=/mnt --exclude=/dados* --exclude=usr\/src --exclude=usr.uzip --exclude=rescue --exclude=varmfs --exclude=etcmfs --exclude=rootmfs / /mnt/

mkdir /mnt/mnt

echo "# Device        Mountpoint      FStype  Options Dump    Pass#" > /mnt/etc/fstab
echo "/dev/${disco}p2     /               ufs     rw      1       1" >> /mnt/etc/fstab
echo "/dev/${disco}p3     none            swap    sw      0       0" >> /mnt/etc/fstab

sync

umount /mnt

echo "FINALIZADO"
