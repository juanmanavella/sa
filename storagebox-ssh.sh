#!/bin/bash
# 
# https://www.blunix.org/howto-use-hetzner-backup-space-with-rsync/
# 
# Eduardo.


HOST='uxxxxxx.your-storagebox.de'
USER='uxxxxxx'
PASS='xxxxxxxxxxx'
TARGETFOLDER='/backups-servers/'
SOURCEFOLDER='/backups/'
MOUNTFOLDER='/mnt/storagebox'

mkdir -p $MOUNTFOLDER
sshfs -o 'nonempty,IdentityFile=/root/.ssh/storagebox_rsa.pub,reconnect' $USER@$HOST:/ $MOUNTFOLDER

rsync -avz --no-o --no-g $SOURCEFOLDER $MOUNTFOLDER/$TARGETFOLDER

umount $MOUNTFOLDER
