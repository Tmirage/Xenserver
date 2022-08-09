#!/bin/sh -x

#Variabelen toekennen
#VMName=10001_33  #de naam van de aangemaakte vm
#SnapshotSuffix=120625_122548
#Action=3

VMName=$1
SnapshotSuffix=$2
Action=$3
post=datausage
SnapshotName=${VMName}_${SnapshotSuffix}

#Controlern of de vmname cq de server wel bestaat
cusid=$(xe vm-list --minimal name-label=${VMName})

if [ -z "${cusid}" ] ; then
	uitkomst=`/usr/bin/curl -X POST -d "200" http://nloup.dlinkddns.com:82/${post} |
	/root/scripts/library/json.sh |
	grep -F -e [\"ResponseResult\"] |
	cut -s -f 2 -d '	'`

	if [ $uitkomst = "0" ] ; then
		else
			echo "doe niks waarde anders dan 0 gevonden"
	fi
exit
fi

#het aanmaken van de snapshot
if [ `"${Action}" | tr [:upper:] [:lower:]` = `"create" | tr [:upper:] [:lower:]` ]; then 
 #controleren of er al een snapshot bestaat met deze naam $SnapshotName
 bestaat=$(xe snapshot-list --minimal name-label="${SnapshotName}")
 if [ -n "$bestaat" ]; then
	uitkomst=`/usr/bin/curl -X POST -d "201" http://nloup.dlinkddns.com:82/${post} |
	/root/scripts/library/json.sh |
	grep -F -e [\"ResponseResult\"] |
	cut -s -f 2 -d '	'`

	if [ $uitkomst = "0" ] ; then
		else
			echo "doe niks waarde anders dan 0 gevonden"
	fi
 exit
 fi    
xe vm-snapshot vm="${VMName}" new-name-label="${SnapshotName}" > /dev/null
#Controleren of de snapshot bestaat nadat deze aangemaakt is
aangemaakt=$(xe snapshot-list --minimal name-label="${SnapshotName}")
 if [ -z "$aangemaakt" ]; then
	uitkomst=`/usr/bin/curl -X POST -d "202" http://nloup.dlinkddns.com:82/${post} |
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
exit
fi


#Het restoren van de snapshot
if [ `"${Action}" | tr [:upper:] [:lower:]` = `"revert" | tr [:upper:] [:lower:]` ]; then 
snapshotuuid=$(xe snapshot-list --minimal name-label="${SnapshotName}")
xe snapshot-revert snapshot-uuid=${snapshotuuid} 
 #controleren aan de hand van de exit code of er niet meerdere snapshots met dezelfde naam zijn
 if [[ $? -eq 1 && -n $snapshotuuid ]]; then
  	uitkomst=`/usr/bin/curl -X POST -d "203" http://nloup.dlinkddns.com:82/${post} |
	/root/scripts/library/json.sh |
	grep -F -e [\"ResponseResult\"] |
	cut -s -f 2 -d '	'`

	if [ $uitkomst = "0" ] ; then
		else
			echo "doe niks waarde anders dan 0 gevonden"
	fi
  exit
 fi
 #Controleren of er wel een snapshot bestaat met de naam $SnapshotName
 if [ -z "$snapshotuuid" ]; then
	uitkomst=`/usr/bin/curl -X POST -d "204" http://nloup.dlinkddns.com:82/${post} |
	/root/scripts/library/json.sh |
	grep -F -e [\"ResponseResult\"] |
	cut -s -f 2 -d '	'`

	if [ $uitkomst = "0" ] ; then
		else
			echo "doe niks waarde anders dan 0 gevonden"
	fi
  exit
 fi
#Het opstarten van de virtual machine
xe vm-start vm="${cusid}"
#controleren of de VM daadwerkelijk goed gestart is
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" != "running" ] ; then
	uitkomst=`/usr/bin/curl -X POST -d "205" http://nloup.dlinkddns.com:82/${post} |
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

exit
fi

#Het verwijderen van de snapshot
if [ `"${Action}" | tr [:upper:] [:lower:]` = `"delete" | tr [:upper:] [:lower:]` ]; then
snapshotuuid=$(xe snapshot-list --minimal name-label="${SnapshotName}")
(echo  yes) | xe snapshot-uninstall snapshot-uuid=${snapshotuuid} > /dev/null
#controleren aan de hand van de exit code of er niet meerdere snapshots met dezelfde naam zijn om te verwijderen
 if [[ $? -eq 1 && -n $snapshotuuid ]]; then
	uitkomst=`/usr/bin/curl -X POST -d "206" http://nloup.dlinkddns.com:82/${post} |
	/root/scripts/library/json.sh |
	grep -F -e [\"ResponseResult\"] |
	cut -s -f 2 -d '	'`

	if [ $uitkomst = "0" ] ; then
		else
			echo "doe niks waarde anders dan 0 gevonden"
	fi
 exit
 fi
 #Controleren of de snapshot daadwerkelijk goed verwijderd is
 if [ -z "$snapshotuuid" ]; then
	uitkomst=`/usr/bin/curl -X POST -d "207" http://nloup.dlinkddns.com:82/${post} |
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
exit
fi          
