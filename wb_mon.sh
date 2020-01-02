#!/bin/sh
#+------------+
#+ -- Vars -- +
#+------------+
SAIDA=''
date +'FORMAT' 1>/dev/null
date +'%m/%d/%Y' 1>/dev/null
date +'%r' 1>/dev/null
NOW=" 

==================== $(date +'%m/%d/%Y') | $(date +'%r') ==================== 

"
#+--------------+
#+ -- checks -- +
#+--------------+
case $1 in
   "man")
      printf "MANUAL FOR WB_MON.SH

This script was created to monitor running processes.

Usage Modes:

To monitor a specific process use:
\$1 = '-proc' \$PROCCESSNAME
   Example: -proc pmon

\$3 = '-path' (to pass the path where the log will be created)
   Example: -path ~ /name.log
NOTE: Use of this parameter is optional, otherwise log file will be created in /tmp/wb_mon.log

------------
To monitor all processes just run the script and if you want to name the place where it will be saved use '-path' for example:

   wb_mon.sh -path ~ / file.log

------------
If you want to use all the 'default' values ​​use only

   wb_mon.sh

------------
If you need to monitor every X minutes add this to user crontab:

crontab -e (to enter cron edit mode)

add a new line:

*/x * * * * /path/wb_script.sh \$1 \$2 \$3 \$4

Remember to replace the \$@ values ​​as needed (what each value means is above)
Replace X to value of minutes do u need



"
;;
   "-proc")
      printf "\n\n%-120s" "Extraindo log de $2"
      sleep 2
      if [ ! -z $3 ] && [ $3 == '-path' ] && [ -d ${4%/*} ]; then
         echo $NOW >> $4
         ps -ef | grep $2 | grep -v 'grep' | grep -v 'wb_mon.sh' >> $4 
         SAIDA=$?
      else
         echo $NOW >> /tmp/wb_mon.log
         ps -ef | grep $2 | grep -v 'grep' | grep -v 'wb_mon.sh' >> /tmp/wb_mon.log
         SAIDA=$?
         printf "LOG salvo em /tmp/wb_mon.log"

      fi
      if [ $SAIDA -eq "0" ]; then echo -e "[    OK    ]"; else exit; fi
      
   ;;
   "-path")
      echo $NOW >> $4
      printf "\n\n%-120s" "Extraindo log de todos os processos"
      sleep 2
      if [ -d ${4%/*} ]; then
         ps -ef | grep -v 'wb_mon.sh' >> $4
         SAIDA=$?
      else
         echo $NOW >> /tmp/wb_mon.log 
         ps -ef | grep -v 'wb_mon.sh' >> /tmp/wb_mon.log
         SAIDA=$?
      fi
      if [ $SAIDA -eq "0" ]; then echo -e "[    OK    ]"; else exit; fi
   ;;
   *)
      echo $NOW >> /tmp/wb_mon.log
      printf "\n\n%-120s" "Extraindo log de todos os processos $2"
      sleep 2
      ps -ef | grep -v 'wb_mon.sh' >> /tmp/wb_mon.log
      SAIDA=$?
      if [ $SAIDA -eq "0" ]; then echo -e "[    OK    ]"; else exit; fi
   ;;
esac