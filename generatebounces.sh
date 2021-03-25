#!/bin/bash

# Heavily based on https://www.lexo.ch/blog/2019/12/solved-postfix-mail-bounce-statistics-script-receive-hourly-bounced-mail-statistics/
# Modified to automatically block bounced addresses and report on a 24 hours period.
export LC_ALL=en_US.utf8

# txt file containing discarded email addresses
# to be served by any web server:
TXT=/var/www/html/blacklisted.txt

MAILLOG=/var/log/mail.log # which log to process

LOGMAILFROM="Bounce Processor<bounces@yourdomain.tld>"
LOGMAILTO="email1@domain.tld email2@domain.tld"               

TIME_START=$(date +"%s") # for logging purposes

WHITELIST="domain.tld|otherdomain.tld|thirddomain.tld" # pipe separated list of domains to whitelis

ALLBOUNCES=`cat ${MAILLOG} |egrep "$(date -d '-24 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-23 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-23 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-21 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-20 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-19 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-18 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-17 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-16 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-15 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-14 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-13 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-12 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-11 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-10 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-9 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-8 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-7 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-6 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-5 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-4 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-3 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-2 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`
ALLBOUNCES+=`cat ${MAILLOG} |egrep "$(date -d '-1 hour' '+%b %e %H').*postfix/smtp.*status=bounced"`

# Backup the transport file:
cp /etc/postfix/transport /root/transport/transport-"$(date +"%m-%d-%y")"

# TMP Files related stuff:
> /tmp/bounces
> $TXT


COUNTBOUNCES=$( [ -n "$ALLBOUNCES" ] && echo "$ALLBOUNCES" | wc -l || echo 0 )

if [ ${COUNTBOUNCES} -gt 0 ]; then
        MAILINFO='<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"><html><head><title></title>'
        MAILINFO+='<style>'
        MAILINFO+='.mainTable { border-collapse: collapse; } .mainTable th, .mainTable td { border:1px dotted #cccccc; text-align:left; vertical-align:top; padding:5px 10px; } .mainTable th { border-bottom: 2px solid #cccccc; }'
        MAILINFO+='.additionalTable { border-collapse: collapse; } .additionalTable td { border: 0px; text-align: left; vertical-align: top; padding: 5px 10px; }'
        MAILINFO+='</style>'
        MAILINFO+='</head><body><table class="mainTable">'
        MAILINFO+="<tr><th>DATE & TIME</th><th>MAIL ID</th><th>CLIENT PTR</th><th>CLIENT IP</th><th>USERNAME</th><th>MAIL FROM</th><th>MAIL TO</th><th>HOST</th><th>HOST IP</th><th>REASON</th><th>SUBJECT</th></tr>"

        while IFS= read -r BOUNCE
                do
                BOUNCE="${BOUNCE//$'\n'/ }"

                MAILID=$(perl -pe "s/.*?postfix\/smtp\[\w+\]:\s(\w+).*/\1/g" <<< ${BOUNCE})
                MAILTO=$(perl -pe "s/.*to=<(.*?)>.*/\1/g" <<< ${BOUNCE})
                DATETIME=$(perl -pe "s/^(\w+\s+\w+\s+\w+:\w+:\w+)\s.*/\1/g" <<< ${BOUNCE})

                NEEDLE=".*?\(host\s.*?\[.*"
                if [[ "${BOUNCE}" =~ ${NEEDLE} ]]; then
                        HOST=$(perl -pe "s/.*?\(host\s(.*?)\[.*/\1/g" <<< ${BOUNCE})
                        HOSTIP=$(perl -pe "s/.*?\(host\s.*?\[(.*?)\]\s.*/\1/g" <<< ${BOUNCE})
                else
                        HOST="<span style='color:#888888;'><i>No host found</i></span>"
                        HOSTIP="<span style='color:#888888;'><i>No IP found</i></span>"
                fi

                NEEDLE=".*\ssaid:\s.*"
                if [[ "${BOUNCE}" =~ ${NEEDLE} ]]; then
                        REASON=$(perl -pe "s/.*\ssaid:\s(.*)/\1/g" <<< ${BOUNCE})
                else
                        ## Check if perhaps the domain could not be resolved (Host not found message). In that case there would be no said
                        NEEDLE=".*\(Host or domain name not found.*"
                        BOUNCE_MSG_PRESENT=".*?status=bounced\s\(.*"
                        if [[ "${BOUNCE}" =~ ${NEEDLE} ]]; then
                                REASON=$(perl -pe "s/.*?\((Host or domain name not found.*)/\1/g" <<< ${BOUNCE})
                        elif [[ "${BOUNCE}" =~ ${BOUNCE_MSG_PRESENT} ]]; then
                                REASON=$(perl -pe "s/.*?status=bounced\s\((.*?)\)/\1/g" <<< ${BOUNCE})
                        else
                                REASON="<span style='color:#888888;'><i>Reject reason not found.</i></span>"
                        fi
                fi

                MESSAGEDATA=$(cat ${MAILLOG} |grep ${MAILID})
                MESSAGEDATA="${MESSAGEDATA//$'\n'/ }"

                NEEDLE=".*sasl_username.*"
                if [[ "${MESSAGEDATA}" =~ ${NEEDLE} ]]; then
                        USERNAME=$(perl -pe "s/.*?sasl_username=(.*?)\s.*/\1/gm" <<< ${MESSAGEDATA})
                        SASL_CLIENT_PTR=$(perl -pe "s/.*?client=(.*?)\[.*/\1/gm" <<< ${MESSAGEDATA})
                        SASL_CLIENT_IP=$(perl -pe "s/.*?client=.*?\[(.*?)\].*/\1/gm" <<< ${MESSAGEDATA})
                else
                        USERNAME="<span style='color:#888888;'><i>local delivery (non-delivery notification)</i></span>"
                        SASL_CLIENT_PTR="<span style='color:#888888;'><i>No PTR found</i></span>"
                        SASL_CLIENT_IP="<span style='color:#888888;'><i>No IP found</i></span>"
                fi

                NEEDLE=".*?header\sSubject:\s.*?\sfrom\s.*"
                if [[ "${MESSAGEDATA}" =~ ${NEEDLE} ]]; then
                        SUBJECT=$(perl -pe "s/.*?header\sSubject:\s(.*?)\sfrom\s.*/\1/gm" <<< ${MESSAGEDATA})
                else
                        NEEDLE=".*sender non-delivery notification.*"
                        if [[ "${MESSAGEDATA}" =~ ${NEEDLE} ]]; then
                                SUBJECT="<span style='color:#888888;'><i>No subject (delivery notification)</i></span>"
                        else
                                SUBJECT="<span style='color:#888888;'><i>No subject (reason unknown)</i></span>"
                        fi
                fi

                MAILFROM=$(perl -pe "s/.*?from=<(.*?)>.*/\1/gm" <<< ${MESSAGEDATA})

                MAILINFO+="<tr><td>${DATETIME}</td><td>${MAILID}</td><td>${SASL_CLIENT_PTR}</td><td>${SASL_CLIENT_IP}</td><td>${USERNAME}</td><td>${MAILFROM}</td><td>${MAILTO}</td><td>${HOST}</td><td>${HOSTIP}</td><td>${REASON}</td><td>${SUBJECT}</td></tr>"

	echo "${MAILTO}				discard:silently" >> /tmp/bounces

        done <<< "$ALLBOUNCES"

        MAILINFO+="</table></body></html>"
        MAILINFO+="<br/><br/><h3>Additional information</h3>"
        MAILINFO+="<table class='additionalTable'>"
        TIME_DIFF=$(($(date +"%s")-${TIME_START}))
        MAILINFO+="<tr><td><strong>Script runtime:</strong></td><td>$((${TIME_DIFF} / 60)) Minutes</td><td>$((${TIME_DIFF} % 60)) Seconds</td><td></td></tr>"
        MAILINFO+="</table></body></html>"

	sort /tmp/bounces | grep -Ev "$WHITELIST" | uniq >> /etc/postfix/transport
	postmap /etc/postfix/transport
	service postfix reload

	echo "Ultima actualizacion: `date`" > $TXT
	grep discard /etc/postfix/transport | awk '{ print $1 }' >> $TXT

        if [ ${COUNTBOUNCES} -gt 50 ]; then BOUNCEWARNING="WARNING | "; else BOUNCEWARNING=""; fi
        echo ${MAILINFO} | mail -a "From: ${LOGMAILFROM}" -a "MIME-Version: 1.0" -a "Content-Type: text/html; charset=utf-8" -s "${BOUNCEWARNING}${COUNTBOUNCES} Mail Bounce(s) Registered at `hostname -f`" ${LOGMAILTO}
fi

