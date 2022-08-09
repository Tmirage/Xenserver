#!/bin/sh -x

#Variabelen toekennen
#VMName=10001_25                 #de naam van de aangemaakte vm
#Cores=1                               #hoeveelheid cpu's
#Memory=2147483648                      #in bytes
#Storage=10
#HA=True
#BackupStorage=0 
#ReCreateOS=True                        #grootte van de harddisk
#OSTemplateName=Debian_Squeeze_6

VMName=$1 
Cores=$2                               
MemoryGB=$3                      
Storage=$4
HA=$5
BackupStorage=$6                         
ReCreateOS="$7"
OSTemplateName="$8"
HostName="$9"

post=datausage

100="100-De image is helaas niet succesvol gedeinstalleerd en kan derhalve niet opnieuw aangemaakt worden"
101="101-$vmname bestaat al en kan derhalve niet meer aangemaakt worden"
102="102-De image is helaas niet succesvol aangemaakt"
103="103-de vm kon niet worden gevonden en derhalve kan het juiste sjabloon niet toegepast worden."
104="104-De hoeveelheid cores bij vcpu-max komt niet overeen met het gevraagde aantal"
105="105-de hoeveelheid cores bij vpcus-at-startup komt niet overeen met het gevraagde aantal"
106="106-de hoeveelheid geheugen bij memory-static-min komt niet overeen met het gevraagde aantal"
107="107-de hoeveelheid geheugen bij memory-static-max komt niet overeen met het gevraagde aantal"
108="108-de hoeveelheid geheugen bij memory-dynamic-min komt niet overeen met het gevraagde aantal"
109="109-de hoeveelheid geheugen bij memory-dynamic-max komt niet overeen met het gevraagde aantal"
110="110-er is geen virtuele harddisk gevonden in deze image om in grootte aan te passen derhalve is de grootte niet aangepast naar de gevraagde hoeveelheid"
111="111-De harddisk grootte is helaas niet corrrect aangepast dit kan gekomen zijn door te weinig beschikbare ruimte of een andere reden"
112="112-De virtualmachine is helaas niet succesvol in de powerstate running terecht gekomen deze is derhalve niet correct opgestart en dus niet bereikbaar"
113="113-verkleinen van de storage is niet toegestaan"
114="114-Als de VM draait bij aanpassingen van de cpu/memory waardes meldt dat deze afgesloten dient te zijn"
115="115-de hoeveelheid geheugen bij memory-static-min komt niet overeen met het gevraagde aantal"
116="116-de hoeveelheid geheugen bij memory-static-max komt niet overeen met het gevraagde aantal"
117="117-de hoeveelheid geheugen bij memory-dynamic-min komt niet overeen met het gevraagde aantal"
118="118-de hoeveelheid geheugen bij memory-dynamic-max komt niet overeen met het gevraagde aantal"
119="119-De hoeveelheid cores bij vcpu-max komt niet overeen met het gevraagde aantal"
120="120-de hoeveelheid cores bij vpcus-at-startup komt niet overeen met het gevraagde aantal"
121="121-de vm is helaas niet succesvol verwijderd bij het opnieuw aanmaken van het OS"
000="0-het script is succesvol afgerond en de VM is aangemaakt of verwijderd en opnieuw aangemaakt."

let Memory="$MemoryGB*1024*1024*1024"

echo vmname=$VMName >/tmp/parameters.txt
echo cores=$Cores >>/tmp/parameters.txt
echo memory=$Memory >>/tmp/parameters.txt
echo storage=$Storage >>/tmp/parameters.txt
echo ha=$HA >>/tmp/parameters.txt
echo backupstorage=$backupstorage >>/tmp/parameters.txt
echo recreateos=$ReCreateOS >>/tmp/parameters.txt
echo ostemplatename=$OSTemplateName >>/tmp/parameters.txt
echo hostnaam=$HostName >> /tmp/parameters.txt


#het verwijderen van de Virtual machine als recreateos = yes
if [ `echo "${ReCreateOS}" | tr [:upper:] [:lower:]` = `echo "true" | tr [:upper:] [:lower:]` ] ; 
then
cusid=$(xe vm-list --minimal name-label=${VMName})
 if [ -z "${cusid}" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "100" http://nloup.dlinkddns.com:82/${post} |
/root/scripts/library/json.sh |
grep -F -e [\"ResponseResult\"] |
cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi
xe vm-uninstall vm=${VMName} force=true > /dev/null
#controleren of de image succesvol verwijderd is bij recreateos = yes
cusid=$(xe vm-list --minimal name-label=${VMName})
 if [ -n "${cusid}" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "121" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi
fi


#controleren of de $vmname bestaat
cusid=$(xe vm-list --minimal name-label=${VMName})

#indien deze al bestaat pas configuratie waardes aan naar de nieuwe gevraagde waardes
if [ -n "${cusid}" ] ; then

#controleren of de storage overeenkomt met de al aanwezige grootte
#het oproepen/editen van de diskuuid voor het aanpassen van de VHD
duuid2=$(xe vm-disk-list --minimal name-label=${VMName})
#Het inlezen van de tijdelijke VHD variabele
duuid=$(echo ${duuid2} | cut -f1 -d",")

disksize2=$(xe vdi-list uuid="${duuid}" params=virtual-size --minimal)
let disksize="$disksize2/1024/1024/1024"
#echo disksize = $disksize

#Controleren of alle 4 de waardes overeenkomen met de gevraagde waarde
staticmin=$(xe vm-param-get uuid="${cusid}" param-name=memory-static-min)
staticmax=$(xe vm-param-get uuid="${cusid}" param-name=memory-static-max)
dynamicmin=$(xe vm-param-get uuid="${cusid}" param-name=memory-dynamic-min)
dynamicmax=$(xe vm-param-get uuid="${cusid}" param-name=memory-dynamic-max)
#het controleren van de hoeveelheid toegewezen cores
Corescontrole=$(xe vm-param-get uuid=${cusid} param-name=VCPUs-max)
Corescontrole2=$(xe vm-param-get uuid=${cusid} param-name=VCPUs-at-startup)

#als de gevraagde storage kleiner is dan de huidige storage exit aangezien dit misgaat en niet mogelijk is zonder het OS opnieuw aan te maken.
if [ "$Storage" -lt "${disksize}" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "113" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi
 
 #als al deze waardes overeenkomen is er alleen een storage aanpassing en is het script hier klaar.
 if [ "$dynamicmax" = "$Memory" ] && [ "$dynamicmin" = "$Memory" ] && [ "$staticmax" = "$Memory" ] && [ "$staticmin" = "$Memory" ] && [ "$Corescontrole2" = "$Cores" ] && [ "$Corescontrole" = "$Cores" ] && [ "$Storage" = "${disksize}" ]; then
  #if [ "$Storage" = "${disksize}" ]
  #De vm bestaat en er zijn geen aanpassingen geconstateerd aan de cpu of memory.
  uitkomst=`/usr/bin/curl -X POST -d "112" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi

#als de waardes hierboven niet overeen komen controleren of de VM afgesloten is indien niet het geval geef foutmelding
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" = "running" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "114" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi

#het oproepen/editen van de diskuuid voor het aanpassen van de VHD
#if [ "$Storage" != "${disksize}" ] ; then
 duuid2=$(xe vm-disk-list --minimal name-label=${VMName})
 #Het inlezen van de tijdelijke VHD variabele
 duuid=$(echo ${duuid2} | cut -f1 -d",")
 #het aanpassen van de storage aan de nieuwe gevraagde waarde
 xe vdi-resize uuid="${duuid}" disk-size="${Storage}GiB"
#fi

#Het aanpassen van het aantal cpu's naar het nieuwe aantal indien afgesloten
if [ "$Corescontrole2" != "$Cores" ] && [ "$Corescontrole" != "$Cores" ] ; then
 xe vm-param-set uuid=${cusid} VCPUs-max="$Cores"
 xe vm-param-set uuid=${cusid} VCPUs-at-startup="$Cores"

 if [ "$Corescontrole2" != "$Cores" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "119" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi
 
 if [ "$Corescontrole" != "$Cores" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "120" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi

fi

#Het aanpassen van het geheugen van de oude naar de nieuwe situatie indien afgesloten
if [ "$dynamicmax" != "$Memory" ] && [ "$dynamicmin" != "$Memory" ] && [ "$staticmax" != "$Memory" ] && [ "$staticmin" != "$Memory" ] ; then
 xe vm-memory-limits-set vm="${cusid}" static-min="${Memory}" static-max="${Memory}" dynamic-min="${Memory}" dynamic-max="${Memory}"

#Controleren of alle 4 de waardes overeenkomen met de gevraagde waarde cq is het aangepast allemaal
 staticmin=$(xe vm-param-get uuid="${cusid}" param-name=memory-static-min)
 if [ "$staticmin" != "$Memory" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "115" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi
 staticmax=$(xe vm-param-get uuid="${cusid}" param-name=memory-static-max)
 if [ "$staticmax" != "$Memory" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "116" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi
 dynamicmin=$(xe vm-param-get uuid="${cusid}" param-name=memory-dynamic-min)
 if [ "$dynamicmin" != "$Memory" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "117" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi
 dynamicmax=$(xe vm-param-get uuid="${cusid}" param-name=memory-dynamic-max)
 if [ "$dynamicmax" != "$Memory" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "118" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
  exit
 fi
fi
#De aanpassingen aan de cpu of geheugen zijn doorgevoerd en dit script is daarmee afgelopen.
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


#het aanmaken van de Virtual machine
xe vm-install new-name-label="${VMName}" template="${OSTemplateName}" > /dev/null

#nagaan of de image zonder fouten is aangemaakt
if [ "$?" != "0" ]; then
  uitkomst=`/usr/bin/curl -X POST -d "102" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi

#de vm cusid opvragen en wegschrijven indien aanwezig
cusid=$(xe vm-list --minimal name-label=${VMName})

#controleren of de cusid niet leeg is
if [ -z "${cusid}" ] ; then
  uitkomst=`/usr/bin/curl -X POST -d "103" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi

#het aanpassen van de cpu's naar het gevraagde aantal
xe vm-param-set uuid=${cusid} VCPUs-max="$Cores"

#het controleren van de hoeveelheid toegewezen cores
Corescontrole=$(xe vm-param-get uuid=${cusid} param-name=VCPUs-max)
if [ "$Corescontrole" != "$Cores" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "104" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi

#het aanpassen van de cpu's naar het gevraagde aantal
xe vm-param-set uuid=${cusid} VCPUs-at-startup="$Cores"

#het controleren van de hoeveelheid toegewezen cores
Corescontrole2=$(xe vm-param-get uuid=${cusid} param-name=VCPUs-at-startup)
if [ "$Corescontrole2" != "$Cores" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "105" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi

#het aanpassen van het geheugen naar de gevraagde hoeveelheid
xe vm-memory-limits-set vm="${cusid}" static-min="${Memory}" static-max="${Memory}" dynamic-min="${Memory}" dynamic-max="${Memory}"

#Controleren of alle 4 de waardes overeenkomen met de gevraagde waarde
staticmin=$(xe vm-param-get uuid="${cusid}" param-name=memory-static-min)
if [ "$staticmin" != "$Memory" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "106" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi
staticmax=$(xe vm-param-get uuid="${cusid}" param-name=memory-static-max)
if [ "$staticmax" != "$Memory" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "107" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi
dynamicmin=$(xe vm-param-get uuid="${cusid}" param-name=memory-dynamic-min)
if [ "$dynamicmin" != "$Memory" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "108" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi
dynamicmax=$(xe vm-param-get uuid="${cusid}" param-name=memory-dynamic-max)
if [ "$dynamicmax" != "$Memory" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "109" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi

#het oproepen/editen van de diskuuid voor het aanpassen van de VHD
duuid2=$(xe vm-disk-list --minimal name-label=${VMName})
#Het inlezen van de tijdelijke VHD variabele
duuid=$(echo ${duuid2} | cut -f1 -d",")

#controleren of de gevraagde duuid wel klopt en dus aanwezig is
if [ -z "${duuid}" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "110" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi

#Het resizen van de VHD
xe vdi-resize uuid="${duuid}" disk-size="${Storage}GiB"
disksize2=$(xe vdi-list uuid="${duuid}" params=virtual-size --minimal)
let disksize="$disksize2/1024/1024/1024"
#echo disksize = $disksize

#controleren of de storage overeenkomt met de (nieuwe) aangevraagde grootte
if [ "$Storage" != "${disksize}" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "111" http://nloup.dlinkddns.com:82/${post} |
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
xe vm-start vm="${cusid}" on=${HostName}

#controleren of de VM daadwerkelijk goed gestart is
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
if [ "$state" != "running" ] ; then
 xe vm-uninstall vm=${VMName} force=true >/dev/null
  uitkomst=`/usr/bin/curl -X POST -d "112" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi
 exit
fi

#het script is succesvol afgerond en de VM is aangemaakt of verwijderd en opnieuw aangemaakt.
  uitkomst=`/usr/bin/curl -X POST -d "0" http://nloup.dlinkddns.com:82/${post} |
  /root/scripts/library/json.sh |
  grep -F -e [\"ResponseResult\"] |
  cut -s -f 2 -d '	'`

if [ $uitkomst = "0" ] ; then
	else
		echo "doe niks waarde anders dan 0 gevonden"
fi 
