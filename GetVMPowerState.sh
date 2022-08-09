#!/bin/sh

#Variabelen toekennen
VMName=$1

post=datausage

#Controleren of de vmname cq de server wel bestaat
cusid=$(xe vm-list --minimal name-label=${VMName})

#De status van de VM controleren
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)

if [ "${state}" = "rebooted" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "reboot" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
exit
fi

if [ "${state}" = "halted" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "halted" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
exit
fi

if [ "${state}" = "running" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "running" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
exit
fi

if [ "${state}" = "suspended" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "suspended" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
exit
fi
