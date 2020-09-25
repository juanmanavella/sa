#!/bin/bash

if [[ $# -eq 0 ]] ; then
    printf "Modo de uso:\n\n $0 direccion@de.email threshold\n\n"
    exit 0
fi

LOG=/var/log/mail.log
TMP=/tmp/spamcheck.txt
HOSTNAME=`hostname -f`
SPAM=0

# Maxmimum number of email addresses to fetch
MAX=5  

# Threshold to send email alerts
THR=$2

# Email address to send the alerts>
EMAILADDR=$1

# Alert email subject
SUBJ="Alerta - posible SPAM enviado desde $HOSTNAME"


> $TMP

# Get the five first most active email accounts:
grep sasl_username $LOG | cut -d "=" -f 4 | sort | uniq -c | sort -nr | head -n $MAX >> $TMP

for COUNT in {1..5}
 do
 TOTAL=`grep -m $COUNT [0-9] $TMP | tail -n1 | awk '{ print $1 }'`
  if (( TOTAL > THR )) 
   then SPAM=1
  fi
done

if [[ "$SPAM" == 1 ]]; 
 then cat $TMP | mail -s "$SUBJ" $EMAILADDR
fi

