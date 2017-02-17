##
## Generic dynamic DNS A record updater for using with afraid.org and such.
## It takes a locally resolvable hostname as argument and updates the given
## A records whenever it's IP number changes.
##
## Also published here: 
## 
## http://www.malditonerd.com/tip-actualizar-dyndns-zoneedit-o-afraid-org-cuanto-cambie-tu-numero-de-ip-wan/ 
##


#!/bin/bash

DNS=`host $1 | tr -d "\n" | sed -e 's/.*address //' -e 's/l.*$//'`

if [ -n "$DNS" ];
then
	WAN=`wget -q -O - checkip.dyndns.org|sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
		if [ -n "$WAN" ];
	        then
			if [ "$WAN" != "$DNS" ]; then

#			echo $WAN | mail -s "Nuevo IP en `echo $hostname`: $WAN" you@example.net 	# mail notificacions
            			

## Update your A records. Change this to your custom URLs:
 
			curl -k http://freedns.afraid.org/dynamic/update.php?UnE2C 
			curl -k http://freedns.afraid.org/dynamic/update.php?UnE2e
			curl -k http://freedns.afraid.org/dynamic/update.php?UnE2e


			sleep 1
			fi
		fi
fi

exit o
