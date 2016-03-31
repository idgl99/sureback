#!/bin/bash
# check or .eml files in /home/log/email
if ls /home/log/email/*.emltest 2>/dev/null 1>&2 
then
  n=0;
  # process each .emltest file
  for i in /home/log/email/*.emltest
  do
    n=$(expr $n + 1)
    # get rid of CRLFs
    /bin/sed 's/$//' $i > /tmp/a$$.$n
    # eml1.awk checks the sendtime.  If it returns 1 it's not time yet
    /bin/awk -f /usr/local/smd/eml1.awk /tmp/a$$.$n
    if [ $? -eq 1 ] 
    then
      # rm /tmp/a$$.$n
      continue
    fi
    # get the values of the escalation and sendto tags to be able to
    # retrieve the recipients.
    escalation=$(grep "^escalation:" /tmp/a$$.$n | /bin/sed 's/escalation://')
    sendto=$(grep "^sendto:" /tmp/a$$.$n | /bin/sed 's/sendto://')
    recipients=$(/usr/local/smd/eml $sendto ${escalation:-0})
    # check if access to the mysql db was succesful
    rc=$?
    if [ $rc -ne 0 ]
    then
      case $rc in
        1) echo "\nERROR: Failed to connect to db?  Maybe mysql is down." >> $i 
           mv $i $(echo $i | /bin/sed 's/eml$/unstest/')  ;;
        2) echo "\nERROR: Select from client_user failed." >> $i 
           mv $i $(echo $i | /bin/sed 's/eml$/unstest/')  ;;
        3) echo "\nERROR: Select from system_user failed." >> $i 
           mv $i $(echo $i | /bin/sed 's/eml$/unstest/')  ;;
        *) echo "\nERROR: Unknown error $rc." >> $i 
           mv $i $(echo $i | /bin/sed 's/eml$/unstest/')  ;;
      esac
      # rm a$$.$n 
      continue
    fi
    # check if recipients were found
    if [ ${#recipients} -lt 2 ] 
    then 
      echo "ERROR: No email addresses found." >> $i 
      mv $i $(echo $i | /bin/sed 's/eml$/unstest/') 
      # rm a$$.$n 
      continue
    fi
    echo "sendmail  $recipients << 'EOM'" >/tmp/b$$.$n
    # check for the sendfrom tag and if present add a From: line
    sendfrom=$(grep "^sendfrom:" /tmp/a$$.$n | /bin/sed 's/sendfrom://')
    if [ ${#sendfrom} -le 1 ]
    then
      sendfrom=$(/usr/local/smd/eml1)
    fi
    echo "From: $sendfrom" >>/tmp/b$$.$n
    # add the To: line
    echo "To: $recipients" >>/tmp/b$$.$n
    # run elm2.awk to create the rest of the mail script in b$$.$n
    /bin/awk -f /usr/local/smd/eml2.awk /tmp/a$$.$n >> /tmp/b$$.$n
    # execute the script to send the mail
    sh /tmp/b$$.$n
    # handle escalation and rewrite the original eml file in /home/log/email
    /bin/awk -f /usr/local/smd/eml3.awk /tmp/a$$.$n > $i
    # remove the temporary files
    #   rm /tmp/a$$.$n /tmp/b$$.$n
    # if escalation  was 2 or if there was no escalation then move .eml to .snt
    if [ ${escalation:-0} -eq 2 -o -z "${escalation}" ]
    then
      mv $i $(echo $i | /bin/sed 's/eml$/snttest/')
      touch $(echo $i | /bin/sed 's/eml$/snttest/')
    fi 
  done
fi
