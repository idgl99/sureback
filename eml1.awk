# get the time to send to message and calculate how many seconds to go
# if negative exit 0 (ready to send message) else exit 1 (not time yet)
BEGIN {FS = ":"
      }

      {
         if ($1 == "sendtime") {
           time = sprintf("%d %d %d %d %d %d",
                     substr($2,1,4),
                     substr($2,5,2),
                     substr($2,7,2),
                     substr($2,9,2),
                     substr($2,11,2),
                     substr($2,13,2));
           sendtime = mktime(time);
           if (sendtime - systime() > 0) {
             exit 1;
           } 
           exit 0;
         }
       }
