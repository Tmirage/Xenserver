#!/bin/sh

#Variabelen toekennen

#VMName="KLANT1498FGJHJ"  		#de naam van de aangemaakte vm
#Action="1"

VMName=$1
Action=$2

#Controleren of de vmname cq de server wel bestaat
cusid=$(xe vm-list --minimal name-label=${VMName})

if [ -z "${cusid}" ] ; then
echo "600"
exit
fi

#Het rebooten van de virtual machine
if [ "${Action}" = `echo "reboot" | tr [:upper:] [:lower:]` ] ; then
 #controleren of de VM wel gestart is zodat hij gereboot kan
 state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" != "running" ] ; then
 echo "601"
 exit
 fi
xe vm-reboot vm="${VMName}" force=true
 #controleren of de VM goed opgestart is na de reboot
 state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" != "running" ] ; then
 echo "602"
 exit
 fi
echo "0"
exit
fi

#Het uitschakelen van de virtual machine
if [ "${Action}" = `echo "halt" | tr [:upper:] [:lower:]` ] ; then
 #Controleren of de server niet al uit staat
 state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" = "halted" ] ; then
 echo "603"
 exit
 fi
xe vm-shutdown vm="${VMName}" force=true
 #Controleren of de server netjes afgesloten is
 state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" != "halted" ] ; then
 echo "604"
 exit
 fi      
echo "0"
exit
fi

#Het opstarten van de virtual machine
if [ "${Action}" = `echo "run" | tr [:upper:] [:lower:]` ] ; then
#controleren of de VM niet al gestart is
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" = "running" ] ; then
   echo "605"
   exit
 fi
 if [ "$state" = "halted" ] ; then
  xe vm-start vm="${VMName}" force=true
  #controleren of de VM goed gestart is
  state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
   if [ "$state" != "running" ] ; then
     echo "606"
     exit
   fi 
 fi
 if [ "$state" = "suspended" ] ; then
  xe vm-resume vm="${VMName}" force=true
  state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
  if [ "$state" != "running" ] ; then
   echo "610"
   exit
  fi
 fi
echo "0"
exit
fi


#Het suspenden van de virtual machine
if [ "${Action}" = `echo "suspend" | tr [:upper:] [:lower:]` ] ; then
#controleren of de VM niet al gestart is
state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" != "running" ] ; then
 echo "607"
 exit
 fi
xe vm-suspend vm="${VMName}" force=true
 #controleren of de VM goed gestart is
 state=$(xe vm-list uuid=${cusid} params=power-state --minimal)
 if [ "$state" != "suspended" ] ; then
 echo "608"
 exit
 fi
echo "0"
exit
fi

echo "400"
exit
fi

