#!/bin/bash -x

#het aanmaken van vlans num is het nummer waarmee de vlan id moet beginnen
# 73 is hierbij het aantal vlans dus vanaf 11 tot en met 73 wordt hier aangemaakt

num=11

master=$(xe pool-list params=master --minimal)
pifuuid=$(xe pif-list device=eth1 host-uuid=$master VLAN=-1 --minimal)


while [ ${num} != 73 ]

do
let num=${num}+1
uuid=$(xe network-create name-label=vlan${num})
xe vlan-create network-uuid=${uuid} pif-uuid=$pifuuid vlan=${num}
#echo ${num} > /tmp/uitkomst.txt

#uitkomst=${num}+1

done
