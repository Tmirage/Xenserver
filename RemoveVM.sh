#!/bin/sh -x

#Variabelen toekennen

#VMName="KLANT1498FGJHJ"                 #de naam van de aangemaakte vm

VMName=$1

post=datausage

#Controleren of de vmname cq de server wel bestaat
cusid=$(xe vm-list --minimal name-label=${VMName})

 if [ -z "${cusid}" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "500" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
 fi


#het verwijderen van de Virtual machine
xe vm-uninstall vm=${VMName} force=true >/dev/null

cusid=$(xe vm-list --minimal name-label=${VMName})

#controleren of de Virtual Machine daadwerkelijk verwijderd is en niet meer bestaat
 if [ -n "${cusid}" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "501" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
 fi
  uitkomst=`/usr/bin/curl -X POST -d "0" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
fi
