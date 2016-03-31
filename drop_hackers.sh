# Remember to update /etc/syslog.conf 
# NOTE repeated password failures for valid jail users will not be stopped
#
# Check for failed logon attempts
awk '/Failed/ {split($0, line, ":");
# First get the IP address
               message = line[4];
               string = " from "
               start = index(message, string);
               if (start = index(message, string)) {
                 ipaddress = substr(message, start + length(string));
                 ipaddress = substr(ipaddress, 1, index(ipaddress, " ") - 1);
               } else {
#                  print("?"ipaddress"?");
               } 
               if (index(message, " password ") != 0) {
                 string = " for "
                 if (start = index(message, string)) {
                   user = substr(message, start + length(string));
                   user = substr(user, 1, index(user, " ") - 1);
                   command = sprintf("grep -q '^%s:' /etc/passwd\n", user);
                   if (user == "invalid" || system(command) == 0) {
# We have found an attempt to logon with a valid unix id and a bad password
# or an attmpt to logon with an invalid user id.  Either way allow three attempts
# from that given address then drop it.
                     ++count[ipaddress];
# print "failed password for", user, " at " ipaddress;
                   }
                 }
               }
              } 
END           {for (ipaddress in count) {
                if (count[ipaddress] > 3) {
                  if (system("iptables -L | grep -q " ipaddress) != 0) {
                    command = sprintf("iptables -I INPUT -p all --source %s -i eth0 -j DROP\n", ipaddress);
                    rc = system(command);
#                   printf("\"%s\" executed with return code of %s\n", command, rc);
                  } else {
#                   print iptables, "already dropped";
                    ;
                  }
                } 
              }
# for (ipaddress in count) print ipaddress, count[ipaddress];
             }' /var/log/logins 
