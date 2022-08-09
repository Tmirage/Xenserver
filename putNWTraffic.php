<html>
<body>
<?php
if (isset($_GET['VMName'])) {
 $VMName = $_GET['VMName'];
 }
if (isset($_GET['startdate'])) {
 $startdate = $_GET['startdate'];
 }
if (isset($_GET['enddate'])) {
 $enddate = $_GET['enddate'];
 }
 
$username="virtualsense";
$password="virtualsense";
$database="networktraffic";

mysql_connect("localhost",$username,$password);
@mysql_select_db($database) or die( "Unable to select database");
$query="select Date,usedRX,usedTX from networktraffic.Traffic where date between '$startdate' and '$enddate' and VMName = '$VMName' ORDER BY Date DESC";
$result=mysql_query($query);

$num=mysql_numrows($result);

mysql_close();

/usr/bin/curl -X POST -d "action=reboot" -d "vm=$VMName" -d "rx=$usedRX" -d "tx=$usedTX" http://www.virtualsense.nl/traffic.php

$i=0;
while ($i < $num) {


