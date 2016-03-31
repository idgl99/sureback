mount /store_backup
if ! vgchange -a y backupvg
then
 logger 'activation of /store_backup failed'
 exit
fi
if ! mount /dev/mapper/backupvg-storelv /store_backup
then
 logger 'mount of /store_backup failed'
 exit
fi
/usr/bin/rsync -a --delete  /store/ /store_backup > /store/backup.log.$(date +%y%m%d) 2>/store/backup.err.$(date +%y%m%d)
/usr/bin/rsync -a   /home/ /store_backup/home > /store/backup_home.log.$(date +%y%m%d) 2>/store/backup_home.err.$(date +%y%m%d)
find /store_backup -name "backup*" -maxdepth 1 -size 0 -exec rm {} \;
umount  /store_backup
vgchange -a n backupvg
/sbin/hdparm  -y /dev/sdb

