# get the time to send the message and add 1 day (week?)
BEGIN {FS = ":"
      }

      {
         if ($1 == "DONOTDEL") {
           escalation = 1
         }
         if ($1 == "escalation") {
           escalation = $2
           if (escalation < 2) {
             ++escalation;
           }
           printf("escalation:%1d\n", escalation);
         }
         else if ($1 == "sendtime") {
           if (escalation < 2) {
             time = sprintf("%d %d %d %d %d %d",
                       substr($2,1,4),
                       substr($2,5,2),
                       substr($2,7,2),
                       substr($2,9,2),
                       substr($2,11,2),
                       substr($2,13,2));
             sendtime = mktime(time);
             if (sendtime < systime()) sendtime = systime();
             printf("sendtime:%14d\n",strftime("%Y%m%d%H%M%S",sendtime+86400));
           } else print $0;
         } else print $0;
      }

