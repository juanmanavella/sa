#!/bin/bash

## Simple script to backup live mounted qcow2 virtual hard disks 
## using qemu-nbd. Just edit the paths below to fit your needs.

LOG=/var/log/105_backup.log

LOCAL_BACKUP=/mnt/12t/backup/rdiff-backup/105
CLOUD_BACKUP=/mnt/12t/cloud/rsync/105-pdc

VDEVICE=/dev/nbd5
VPARTITION=/dev/nbd5p1
VHDD=/mnt/12t/images/105/vm-105-disk-0.qcow2

LOCAL_MOUNT=/mnt/backup/105/



## Runtime: rdiff-backup to a local path and the rsync to any mounted
## cloud backup.

date >> $LOG
modprobe nbd >> $LOG
qemu-nbd -c $VDEVICE $VHDD -r >> $LOG
mount -o ro $VPARTITION $LOCAL_MOUNT >> $LOG
rdiff-backup --exclude $LOCAL_MOUNT System\ Volume\ Information $LOCAL_MOUNT $LOCAL_BACKUP >> $LOG
rsync -a --no-p $LOCAL_BACKUP $CLOUD_BACKUP >> $LOG
sync
umount LOCAL_MOUNT >> $LOG
killall qemu-nbd >> $LOG
printf "\n\n\n" >> $LOG
