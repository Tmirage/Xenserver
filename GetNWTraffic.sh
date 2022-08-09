#!/bin/bash -x
# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
exec 2>&1

#echo "`date`: $0 $*" >> /var/log/traffic.log

action=$1
domain=$2
device=$3

# mysql username
SQLUSER="virtualsense"
# mysql password
SQLPASS="virtualsense"
# mysql server hostname/IP
SQLHOST="192.168.2.18"
# prints date in YYYY-MM-DD format
SQLDATE=$(date +%F-%H:%M:%S)
JSONDATE=$(date +%F"T"%H:%M:%S"Z")
#SQLDATE2=$(date +%FT%H:%M:%SZ)
# database to use (created with: mysql> create database db_whois;)
SQLDB="networktraffic"
# table inside the database to use
SQLTBL="Traffic"
SQLSND="send"
SQLQUE="queue"
# mysql> describe tbl_scraped;
#+-----------+-------------+------+-----+---------+----------------+
#| Field     | Type        | Null | Key | Default | Extra          |
#+-----------+-------------+------+-----+---------+----------------+
#| idTraffic | int(11)     | NO   | PRI | NULL    | auto_increment |
#| RX        | varchar(45) | YES  |     | NULL    |                |
#| TX        | varchar(45) | YES  |     | NULL    |                |
#| VMName    | varchar(45) | YES  |     | NULL    |                |
#| Date      | varchar(45) | YES  |     | NULL    |                |
#| Action    | varchar(45) | YES  |     | NULL    |                |
#+-----------+-------------+------+-----+---------+----------------+
#6 rows in set (0.00 sec)

Hostip=$(/sbin/ifconfig xenbr0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}')
Host=$(xe host-list address=${Hostip} --minimal)

poolid=`xe pool-list --minimal`
poolmaster=`xe pool-param-get uuid=$poolid param-name=master`
masterip=`host-param-get uuid=${poolmaster} param-name=address`

if [ $host = $masterip ] ; then
num=0
rows=`(echo "SELECT COUNT(*) FROM $SQLQUE;"\
|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names)`

while [ ${num} != $rows ];	do

	let num=${num}+1
	
	dbquery=$(echo "SELECT idqueue, VMName, Date, usedRX, usedTX FROM $SQLQUE ORDER BY Date DESC LIMIT 1;"\
	|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names)

	ARRAY=( $( for i in $dbquery ; do echo $i ; done ) )

	echo ${ARRAY[@]}
	
	dbid=`echo ${ARRAY[0]}`
	dbVMName=`echo ${ARRAY[1]}`
	dbJSONDATE=`echo ${ARRAY[2]}`
	dbusedRX=`echo ${ARRAY[3]}`
	dbusedTX=`echo ${ARRAY[4]}`

	uitkomst=`/usr/bin/curl -X POST -d "VMName=$dbVMName" -d "rxBytes=$dbusedRX" -d "txBytes=$dbusedTX" -d "Date=$dbJSONDATE" http://nloup.dlinkddns.com:82/datausage |
	/root/scripts/library/json.sh |
	grep -F -e [\"ResponseResult\"] |
	cut -s -f 2 -d '	'`

	if [ $uitkomst = "0" ] ; then
		echo "INSERT INTO $SQLSND VALUES (NULL,'$VMName','$JSONDATE','$usedRX','$usedTX');"\
		|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
		#echo "nu moet hij gedelete worden maar on behalf of testen even niet"
		echo "DELETE FROM $SQLQUE WHERE idqueue=$dbid;"\
		|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
		else
			echo "doe niks waarde anders dan 0 gevonden"
	fi
	
done

fi

echo domein=$domain device=$device actie=$action >> /tmp/log.txt

if [ "$action" =  "remove" ];  then
exit
fi

if [ "$action" =  "add" ];  then
exit
fi

if [ "$action" =  "online" ];  then
exit
fi


#zodra het een eventuele reboot is schrijf deze waarden weg van de specifieke VM die gereboot wordt
if [ -n "$domain" ] && [ -n "$device" ]; then
	_ETH="vif${domain}.2"
	#Het ophalen van de data van de betreffende interface om er later spannende dingen mee te doen
	_DATA=$(/sbin/ifconfig "$_ETH" 2>/dev/null | /bin/grep RX.*bytes.*TX);
	
	#Het ophalen en juist wegschrijven van de received en transmitted bytes       
	_RX=$(echo $_DATA | /bin/awk '{print $2}' | /bin/cut -b7-)
	_TX=$(echo $_DATA | /bin/awk '{print $6}' | /bin/cut -b7-)
	
	if [ -z $_RX ] && [ -z $_TX ]; then
	echo reboot maar ik exit nu >> /tmp/log.txt
	exit
	fi

		#het geschikt maken van het domainid
		_DOM=`echo $_ETH | /bin/sed 's/vif\([[:digit:]]*\).*/\1/'`;
		#het geschikt maken van het deviceid
		_DEV=`echo $_ETH | /bin/sed 's/.*\.//'`
		
		VMName=`/opt/xensource/bin/xe vm-list dom-id="$_DOM" resident-on=$Host params=name-label --minimal`
		echo "action=reboot" "vm=$VMName" "rx=$_RX" "tx=$_TX" eth=$_eth data=$_data >> /tmp/log.txt
		#/usr/bin/curl -s -H "host: www.virtualsense.nl" -d "action=reboot" -d "vm=$VMName" -d "rx=$_RX" -d "tx=$_TX" http://www.virtualsense.nl/traffic.php

		TX=`echo "select TX from $SQLTBL where VMName = '$VMName' ORDER BY Date DESC LIMIT 1;"\
        |mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names`
        RX=`echo "select RX from $SQLTBL where VMName = '$VMName' ORDER BY Date DESC LIMIT 1;"\
        |mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names`

        let usedRX="$_RX-$RX"
        let usedTX="$_TX-$TX"

        echo $usedRX $usedTX

        echo "INSERT INTO $SQLTBL VALUES (NULL,'$_RX','$_TX','$VMName','${SQLDATE}','reboot','$usedRX','$usedTX');"\
        |mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
		
		uitkomst=`/usr/bin/curl -X POST -d "VMName=$VMName" -d "rxBytes=$usedRX" -d "txBytes=$usedTX" -d "Date=$JSONDATE" http://nloup.dlinkddns.com:82/datausage |
		/root/scripts/library/json.sh |
		grep -F -e [\"ResponseResult\"] |
		cut -s -f 2 -d '	'`

		if [ $uitkomst = "0" ] ; then
			echo "INSERT INTO $SQLSND VALUES (NULL,'$VMName','$JSONDATE','$usedRX','$usedTX');"\
			|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
			else
				echo "INSERT INTO $SQLQUE VALUES (NULL,'$VMName','$JSONDATE','$usedRX','$usedTX');"\
				|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
		fi   
	
else
	#als het script aangeroepen wordt door de crontab schrijf alle waardes van alle vm's weg en rapporteer deze naar een site
	/sbin/ifconfig | /bin/egrep -e '(vif.*.2)' | /bin/awk '{print $1}' | while read _ETH; do
	        _RX=$(/sbin/ifconfig "$_ETH" 2>/dev/null | /bin/grep RX.*bytes.*TX | /bin/awk '{print $2}' | /bin/cut -b7-)
	        _TX=$(/sbin/ifconfig "$_ETH" 2>/dev/null | /bin/grep RX.*bytes.*TX | /bin/awk '{print $6}' | /bin/cut -b7-)
			_DOM=`echo $_ETH | /bin/sed 's/vif\([[:digit:]]*\).*/\1/'`;
			_DEV=`echo $_ETH | /bin/sed 's/.*\.//'`
			VMName=`/opt/xensource/bin/xe vm-list dom-id="$_DOM" resident-on=$Host params=name-label --minimal`
			
			# het adres waarnaar wij de waardes willen POSTen
			echo "action=crontab" "vm=$VMName" "rx=$_RX" "tx=$_TX" >> /tmp/log.txt
			#/usr/bin/curl -s -H "host: www.virtualsense.nl" -d "action=crontab" -d "vm=$VMName" -d "rx=$_RX" -d "tx=$_TX" http://www.virtualsense.nl/traffic.php

			reboot=`echo "select action from $SQLTBL where VMName = '$VMName' ORDER BY Date DESC LIMIT 1;"\
			|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names`
			
			if [ $reboot != "reboot" ] ; then
			TX=`echo "select TX from $SQLTBL where VMName = '$VMName' ORDER BY Date DESC LIMIT 1;"\
			|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names`
		    RX=`echo "select RX from $SQLTBL where VMName = '$VMName' ORDER BY Date DESC LIMIT 1;"\
			|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names`

			let usedRX="$_RX-$RX"
			let usedTX="$_TX-$TX"
		    
		    echo $usedRX $usedTX
		    
			echo "INSERT INTO $SQLTBL VALUES (NULL,'$_RX','$_TX','$VMName','${SQLDATE}','crontab','$usedRX','$usedTX');"\
            |mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
			
				uitkomst=`/usr/bin/curl -X POST -d "VMName=$VMName" -d "rxBytes=$usedRX" -d "txBytes=$usedTX" -d "Date=$JSONDATE" http://nloup.dlinkddns.com:82/datausage |
				/root/scripts/library/json.sh |
				grep -F -e [\"ResponseResult\"] |
				cut -s -f 2 -d '	'`

				if [ $uitkomst = "0" ] ; then
					echo "INSERT INTO $SQLSND VALUES (NULL,'$VMName','$JSONDATE','$usedRX','$usedTX');"\
					|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
					else
						echo "INSERT INTO $SQLQUE VALUES (NULL,'$VMName','$JSONDATE','$usedRX','$usedTX');"\
						|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
				fi

			else		    
		    
		    usedRX=$_RX
		    usedTX=$_TX
		    
			echo "INSERT INTO $SQLTBL VALUES (NULL,'$_RX','$_TX','$VMName','${SQLDATE}','crontab','$usedRX','$usedTX');"\
			|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB

			uitkomst=`/usr/bin/curl -X POST -d "VMName=$VMName" -d "rxBytes=$usedRX" -d "txBytes=$usedTX" -d "Date=$JSONDATE" http://nloup.dlinkddns.com:82/datausage |
			/root/scripts/library/json.sh |
			grep -F -e [\"ResponseResult\"] |
			cut -s -f 2 -d '	'`

				if [ $uitkomst = "0" ] ; then
					echo "INSERT INTO $SQLSND VALUES (NULL,'$VMName','$JSONDATE','$usedRX','$usedTX');"\
					|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
					else
						echo "INSERT INTO $SQLQUE VALUES (NULL,'$VMName','$JSONDATE','$usedRX','$usedTX');"\
						|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB
				fi
			fi
			
	done
fi

