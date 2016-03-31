BEGIN {FS = ":"
        body = 0;
      }

      {
         if ($1 == "subject") {
           for ( i = 2; i <= NF; i++)
             subject = subject $i;
           printf ("Subject: %s\n", subject);
         }
         if ($1 == "type") {
           type = $2;
           if (type == "html") {
             print "Content-Type: multipart/alternative; boundary=\"=-77CrxyULTZqfxGs6Xgbj\"";
             print "Mime-Version: 1.0"
             print "--=-77CrxyULTZqfxGs6Xgbj"
             print "Content-Type: text/html; charset=\"utf-8\""
             print "Content-Transfer-Encoding: 8bit"
           }
         } 

         if (body == 0 &&
             $1 != "sendtime" && $1 !=  "sendto" && $1 != "sendfrom" &&
             $1 != "subject" && $1 != "sendtime" && $1 != "escalation" &&
             $1 != "backupcode" && $1 != "sender" && $1 != "type" && $1 != "DONOTDEL") {
           body = 1;
           printf("\n");
         }
         if (body == 1) {
           print $0;
         }
      }
END {
      if (type == "html") {
        print "--=-77CrxyULTZqfxGs6Xgbj--";
      }
      print "EOM";
    }
