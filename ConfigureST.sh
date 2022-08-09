#!/bin/sh

#Variabelen toekennen
VMName="KLANT1498FGJHJ"  		#de naam van de aangemaakte vm
Storage="11GiB"           		#grootte van de harddisk

#VMName=$1
#Storage=$2

#de vm cusid opvragen en wegschrijven indien aanwezig
cusid=$(xe vm-list --minimal name-label=${VMName})

#het oproepen/editen van de diskuuid voor het aanpassen van de VHD
duuid2=$(xe vm-disk-list --minimal name-label=${VMName})

#Het inlezen van de tijdelijke VHD variabele
duuid=$(echo ${duuid2} | cut -f1 -d",")

#controleren of de gevraagde duuid wel klopt en dus aanwezig is
if [ -z "${duuid}" ] ; then
echo exitstatus "300"
exit
fi

#Controleren of de server niet al uit staat
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
if [ "$state" != "halted" ] ; then
xe vm-shutdown vm="${VMName}" force=true
fi
#Controleren of de server netjes afgesloten is
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
if [ "$state" != "halted" ] ; then
echo existatus "301"
fi
          
#Het resizen van de VHD
xe vdi-resize uuid="${duuid}" disk-size=${Storage}
disksize=$(xe vdi-list uuid="${duuid}" params=virtual-size --minimal)

#controleren of de storage overeenkomt met de (nieuwe) aangevraagde grootte
if [ "$Storage" != "${disksize}" ] ; then
echo existatus "302"
#exit
fi

#Het opstarten van de virtual machine
xe vm-start vm="${cusid}"

#controleren of de VM daadwerkelijk goed gestart is
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
if [ "$state" != "running" ] ; then
echo existatus "303"
#exit
fi

echo existatus "400"
