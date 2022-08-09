<?php
if (isset($_GET['VMName'])) {
 $VMName = $_GET['VMName'];
 }
 
   // Opening an SSH connection
$connection3 = ssh2_connect('localhost', 22);
ssh2_auth_password($connection3, 'root', 'virtualsense');

  //Passing commands to the SSH connection
$stream = ssh2_exec($connection3, "/root/scripts/xenserver/Gettest2.py");
$Master = ssh2_fetch_stream($stream,SSH2_STREAM_STDERR);

  // Block Streaming to let the command finish (it will stop prematurely otherwise)
stream_set_blocking($stream, true);
  // The command may not finish properly if the stream is not read to end
   $Master = stream_get_contents($stream);
   fclose($stream);
   
fwrite($handle, $Master);
  // Opening an SSH connection
$connection = ssh2_connect($Master, 22);
ssh2_auth_password($connection, 'root', 'virtualsense')

  //Passing commands to the SSH connection
$stream = ssh2_exec($connection, "/root/scripts/OpaqueRef.py $VMName");
$output = ssh2_fetch_stream($stream,SSH2_STREAM_STDERR);

  // Block Streaming to let the command finish (it will stop prematurely otherwise)
stream_set_blocking($stream, true);
  // The command may not finish properly if the stream is not read to end
   $output = stream_get_contents($stream);
   fclose($stream);

 echo "<?xml version='1.0'?><results><result><code>$output</code><message></message></result></results>";
?>
