#!/bin/bash -x

#het verwijderen van vlans te beginnen met vlan 11 tot en met 73

num=11


while [ ${num} != 73 ]

do
let num=${num}+1
uuid=$(xe network-list name-label=vlan${num} --minimal)
uuid2=$(echo ${uuid} | cut -f1 -d",")
xe network-destroy uuid=${uuid2}
vlan=${num}
#echo ${num} > /tmp/uitkomst.txt

#uitkomst=${num}+1

done
