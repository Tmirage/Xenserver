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

num=0
rows=`(echo "SELECT COUNT(*) FROM $SQLSND;"\
|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names)`

while [ ${num} != $rows ];	do

	let num=${num}+1
	
	dbquery=$(echo "SELECT VMName, Date, usedRX, usedTX FROM $SQLSND ORDER BY Date DESC LIMIT 1;"\
	|mysql -u$SQLUSER -p$SQLPASS -h$SQLHOST $SQLDB --skip-column-names)

	ARRAY=( $( for i in $dbquery ; do echo $i ; done ) )

	echo ${ARRAY[@]}

	VMName=$(echo ${ARRAY[0]})
	JSONDATE=$(echo ${ARRAY[1]})
	usedRX=$(echo ${ARRAY[2]})
	usedTX=$(echo ${ARRAY[3]})

done