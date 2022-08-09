<?php
if (isset($_GET['VMName'])) {
 $VMName = $_GET['VMName'];
 }
if (isset($_GET['Startdate'])) {
 $Startdate = $_GET['Startdate'];
 }
if (isset($_GET['Enddate'])) {
 $Enddate = $_GET['Enddate'];
 }
 
$username="virtualsense";
$password="virtualsense";
$database="networktraffic";

mysql_connect("192.168.2.18",$username,$password);
@mysql_select_db($database) or die( "Unable to select database");
$query="select Date,usedRX,usedTX from networktraffic.Traffic where Date between '$Startdate' and '$Enddate' and VMName = '$VMName' ORDER BY Date DESC";
$result=mysql_query($query);

$num=mysql_numrows($result);

mysql_close();

$xml_output = "<?xml version=\"1.0\"?>\n"; 
$xml_output .= "<results>\n";
 
$i=0;
while ($i < $num) {

$f1=mysql_result($result,$i,"Date");
$f2=mysql_result($result,$i,"usedRX");
$f3=mysql_result($result,$i,"usedTX");

$xml_output .= "\t<result><code></code>\n";
$xml_output .= "\t\t<message>" . $f1 . "</message>\n";
$xml_output .= "\t\t<message2>" . $f2 . "</message2>\n";
$xml_output .= "\t\t<message3>" . $f3. "</message3>\n";
$xml_output .= "\t</result>\n";

$i++;
}
$xml_output .= "</results>"; 

echo $xml_output;
?>

