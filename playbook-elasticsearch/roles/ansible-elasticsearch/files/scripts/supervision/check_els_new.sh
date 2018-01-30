#!/bin/bash

prog=`basename $0`
numargs="$#"

# Controle qu'il y a au moins 1 argument
if [ $# -le 0 ]; then
  if [ $# -gt 2 ]; then
    echo "ELS 3 : mauvais format d'appel de $prog"
    exit 3
  fi
fi

### CONSTANTS ###
# Alert
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3
### END CONSTANTS ###

### VARIABLES ###
# Si le script est appelé avec deux argument,
# le 2nd argument sera utilisé dans la variable $user :

if [ $# -eq 2 ]; then
  user="$2"
  home_user=`eval "echo ~$user"`
  dir_config=${home_user}/etc/elasticsearch
  pid_dir=${home_user}/var/run/elasticsearch
  PIDFILE=${pid_dir}/${user}_elasticsearch.pid

else

  # Sinon on construit le user :

  # Recuperation info plateforme
  t=`echo "$1" |tr 'A-Z' 'a-z'`
  trigramme=`echo $t | cut -d_ -f1`
  plateforme=`echo $t | cut -d_ -f2 | cut -c 1-3`
  composant=`echo $t | cut -d_ -f4 | cut -c 1-3`
  if [ ! -z ${composant} ];then
    trigramme=`echo $t | cut -d_ -f4`
  fi
  if [[ ! -z ${composant} || "${composant}" = "sec" ]];then
    trigramme=`echo $t | cut -d_ -f1`
  fi
  case $plateforme in
    int) platef=i;;
    rec) platef=o;;
    pre|prep) platef=h;;
    prd|prod) platef=p;;
    *) echo "ELS 3 : plateforme non reconnue"
    exit 1;;
  esac

  num=`echo $t | cut -d_ -f2`
  num=`echo ${num:(-1)}`
  application=`echo $t | cut -d_ -f3`

  user=`echo $trigramme$application$platef$num`

  home_user=`eval "echo ~$user"`
  dir_config=${home_user}/config
  PIDFILE=$(ps -fu $user | grep "Des.pidfile" | grep -v grep | sed 's/.*Des.pidfil[e]=\([^ ]*\).*/\1/')
fi

HTTP_PORT=`strings ${dir_config}/elasticsearch.yml | grep -i http.port | cut -f2 -d":" | sed 's/ //g'`

NAG_MESSAGE=""

### END VARIABLES ###

check_process() {

if [ "$PIDFILE" == "" ]
then
   echo "Aucun process ELS"
   return $CRITICAL
else
   if [ ! -f $PIDFILE ]
   then
      echo "Fichier $PIDFILE absent"
          return $WARNING
   else
      return $OK
   fi
fi

}

check_cluster_health () {

   TMP_CHK_FILE="/tmp/check_cluster_health_$$.tmp"
if [[ ! -z ${composant} || "${composant}" = "sec" ]];then
   echo $HTTP_PORT
   CMD_CHK=`curl -k -XGET 'https://nrpevsc:nrpevsc@localhost:'${HTTP_PORT}'/_cluster/health?pretty=true' > $TMP_CHK_FILE 2>/dev/null`
   chk_rc=$?
   RC=0
else
   CMD_CHK=`curl -XGET 'localhost:'${HTTP_PORT}'/_cluster/health?pretty=true' > $TMP_CHK_FILE 2>/dev/null`
   chk_rc=$?
   RC=0
fi
   if [ $chk_rc -eq 0 ]
   then
      # STATUS
      v_status=`cat $TMP_CHK_FILE | grep status | cut -f2 -d":" | sed 's/ "//g' | sed 's/",//g'`
          if [ "$v_status" != "green" ]
          then
             RC=$WARNING
             if [ "$NAG_MESSAGE" != "" ]; then NAG_MESSAGE=$NAG_MESSAGE" - "; else NAG_MESSAGE="Cluster status : "; fi
             NAG_MESSAGE=$NAG_MESSAGE""$v_status
          fi
          # UNASSIGNED
      v_unassigned=`cat $TMP_CHK_FILE | grep -w "unassigned_shards" | cut -f2 -d":" | sed 's/ //g'| sed 's/,//g'`
          if [ $v_unassigned -ne 0 ]
          then
             RC=$WARNING
             if [ "$NAG_MESSAGE" != "" ]; then NAG_MESSAGE=$NAG_MESSAGE" - Unassigned Shards : "; else NAG_MESSAGE="Unassigned Shards : "; fi
             NAG_MESSAGE=$NAG_MESSAGE""$v_unassigned
          fi
   else
     RC=2
     NAG_MESSAGE="CRIT=cluster"
   fi

   rm $TMP_CHK_FILE
   return $RC

}

check_log() {

   LOG_PATH=`strings ${dir_config}/elasticsearch.yml | grep -i ^path.logs| cut -f2 -d":" | sed 's/ //g'`
   CLUSTER_NAME=`strings ${dir_config}/elasticsearch.yml | grep -i ^cluster.name | cut -f2 -d":" | sed 's/ //g'`

   LOG_FILE=$LOG_PATH"/"$CLUSTER_NAME".log"
   SEEK_FILE=$home_user"/admin/nagios/log/"$CLUSTER_NAME".seek"

 if [ ! -r $LOG_FILE ]; then
   echo "Probleme de lecture du fichier $LOG_FILE"
   return $UNKNOW
 else

   EOF=`ls -lL $LOG_FILE|sed -e 's/\  */./g'|cut -d. -f5`
   if [ ! -f $SEEK_FILE ]
   then
      SEEK=0
   else
      SEEK=`cat $SEEK_FILE`
          if [ $SEEK -gt $EOF ]
          then
            SEEK=0
          fi
   fi

   WARN_MESS=""
   ERR_MESS=""
   RES=0
   if [ `tail -c +$SEEK $LOG_FILE |grep " WARN " | wc -l` -ne 0 ]
   then
      WARN_MESS="Warning detected"
   fi

   if [ `tail -c +$SEEK $LOG_FILE |grep " ERR" | wc -l` -ne 0 ]
   then
      ERR_MESS="Error detected"
   fi

   #if [ "$NAG_MESSAGE" != "" ]; then NAG_MESSAGE=$NAG_MESSAGE" - "; fi

   if [ "$WARN_MESS" != "" ]
   then
      NAG_MESSAGE=$WARN_MESS
          if [ "$ERR_MESS" != "" ]
          then
             NAG_MESSAGE=$NAG_MESSAGE" - "$ERR_MESS
                 RES=$CRITICAL
          else
             RES=$WARNING
          fi
   else
          if [ "$ERR_MESS" != "" ]
          then
             NAG_MESSAGE=$ERR_MESS
                 RES=$CRITICAL
          else
             RES=$OK
          fi
   fi

   echo $EOF > $SEEK_FILE
   if [ "$NAG_MESSAGE" != "" ]; then echo $NAG_MESSAGE; fi
   return $RES

  fi
}

## MAIN

NAG_RETURN=0
check_process
NAG_RETURN=$?
RETURN_LOG=0

if [ $NAG_RETURN -eq 0 ]
then
  if [ -f $NAG_CFG_FILE ]; then check_cluster_health; NAG_RETURN=$?; fi
  check_log
  RETURN_LOG=$?
  if [ $RETURN_LOG -gt $NAG_RETURN ]; then NAG_RETURN=$RETURN_LOG; fi
fi

if [ $NAG_RETURN -eq 0 ]; then
   echo "Elasticsearch OK";
 else
   echo "Elasticsearch KO";
fi

exit $NAG_RETURN

## END

