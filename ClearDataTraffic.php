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

mysql_connect("192.168.2.18",$username,$password);
@mysql_select_db($database) or die( "Unable to select database");
$query="delete from networktraffic.Traffic where Date between '$startdate' and '$enddate' and VMName = '$VMName' ORDER BY Date DESC";
$result=mysql_query($query);

mysql_close();

echo "<?xml version='1.0'?><results><result><code>0</code><message>Delete statement is succesvol uitgevoerd</message></result></results>";
?>

