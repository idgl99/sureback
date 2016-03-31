usage=$(df -h /store | tail -1 | awk '{print$(NF-1)}')
usage=${usage:0:${#usage}-1}
date | grep -q 'Fri'
rc=$?
if [ $usage -gt 90 -o $rc -eq 0 ]
then
  recipients=$(/usr/local/smd/rcv | sed 's/;/ /')
  sender=$(/usr/local/smd/snd)
  vgchange -a y backupvg >/dev/null
  mount /dev/backupvg/storelv /store_backup || ( logger 'mount of /store_backup failed' ; exit ; )
  ( echo From: $sender;
    echo To: $recipients ;
    echo Subject: $(hostname) Disk Usage Report ;
    df -h ) |
    sendmail $recipients
    umount  /store_backup
    vgchange -a n backupvg  >/dev/null
#  /sbin/hdparm  -y /dev/sde >/dev/null
fi
