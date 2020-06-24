#!/bin/bash

if [[ $# -eq 0 ]] ; then
    printf "Modo de uso:\n\n $0 numero_de_extension direccion@de.email\n\n"
    exit 0
fi


>/tmp/$1_lastlog.txt

grep $1 /var/log/asterisk/messages | grep "is now" | tail -n 5 >> /tmp/$1_lastlog.txt

EXTENSION=$1
EMAIL=$2
LASTLOG="/tmp/$1_lastlog.txt"
LASTMAIL="/tmp/$1_lastmail.txt"

if cmp -s "$LASTLOG" "$LASTMAIL"; then
    sleep 1
else
    cp $LASTLOG $LASTMAIL
    tail -n1 $LASTMAIL | grep Reachable > /dev/null &&  cat $LASTMAIL | mail -s "Monitoreo: Interno $EXTENSION restablecido" $EMAIL
    tail -n1 $LASTMAIL | grep UNREACHABLE > /dev/null &&  cat $LASTMAIL | mail -s "Monitoreo: Interno $EXTENSION con problemas" $EMAIL
fi
