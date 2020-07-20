#!/bin/bash

# Monitor to static routes between two endpoints, logs and reports when changes.

if [[ $# -eq 0 ]] ; then
    printf "Modo de uso:\n\n $0 numero de IP direccion@de.email\n\n"
    exit 0
fi

IP=$1
EMAIL=$2
DT="$(date +"%m-%d-%y_%H:%m")"
LASTLOG="/tmp/$1_lastlog-$DT.txt"
LASTMAIL="/tmp/$1_lastmail-$DT.txt"

> $LASTLOG

# Monitor only non routable address space:
traceroute -n $IP | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' |  grep -E "192\.168|10\." | grep -v 10.0.0.1 >> $LASTLOG


if cmp -s "$LASTLOG" "$LASTMAIL"; then
    sleep 1 # do nothing
else
    cp $LASTLOG $LASTMAIL
    cat $LASTMAIL | mail -s "Static routes changed on `hostname -f`: $IP" $EMAIL

fi
