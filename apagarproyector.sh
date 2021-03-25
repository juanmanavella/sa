#/bin/bash

LOG=/tmp/proyector.log
COUNT=/tmp/proyector.runtime

touch $LOG $COUNT

hora=$(date +%H:%M)


if [[ "$hora" > "23:00" ]] || [[ "$hora" < "06:30" ]]; then
	
	# Ver si stremio o netflix estan corriendo
	top=`ssh proyector "top -m 10 -s cpu -n 1" | grep -iE 'stremio|netflix'` && runtime=1 || runtime=0

	# Si el proceso esta en ejecucion:
	if [ ${runtime} -eq 1 ]; then
		# Levantar cuanto proc consume:
		proc=`echo $top | awk '{ print $3 }' | sed 's/\%//'`
		# escribirlo en el log
		date >> $LOG
		echo "proc esta al $proc %" >> $LOG
		# Si esta reproduciendo por que el proc esta encima de 1:
		# mantener la cuenta en 1:
		if [ ${proc} -gt 1 ]; then
			echo 1 > $COUNT # nada por ahora
		else
			# Si no esta reproduciendo incrementar uno la cuenta
			n=`cat $COUNT`
			m=$(( n + 1 ))
			echo $m > $COUNT
		fi
		
	else	
		# Si no esta en ejecucion incrementar uno la cuenta y escribir en el log
		n=`cat $COUNT`
	        m=$(( n + 1 ))
        	echo $m > $COUNT
		date >> $LOG
		echo "No hay procesos en ejecucion" >> $LOG
		if [ $m -gt 10 ]; then
			# apagar el proyector y escribir el log
			date >> $LOG
			echo "-----------APAGANDO-------------"
			echo "-----------APAGANDO-------------"
			echo "-----------APAGANDO-------------"
			echo 1 > $COUNT
			ssh proyector reboot 
		fi
	fi
fi
