<?php
// Put your device token here (without spaces):
//ios 14

$deviceToken = '9054aefb074da12838d965d5b06a4009912b9fb774a7c84ab901afdac2cf0838';
$deviceToken = '085fab8fbebc37476f5ffeb852e9e75a73ac5b311f3220a4fc0c2cd76d64742c';
// $deviceToken = 'afbe6198c28abd209322fa7114fd07a0a7109c1b0230253c0e7460991bf44e56';

//adhoc
// $deviceToken = '7fbb640cbaca9b19ba128f3a73be11f380df5cbfcabc0b71b6efb6209025dc16';

//ios 11  
$deviceToken = 'b88e86beba3abe4c3c98fdb6851766d89a23d82e895d79d32e9867f974bdac3c';
//adhoc
// $deviceToken = 'b7e781ffa42a73a073a602fdafadd973c54e583dbc016ae5a7884bfe182bd9d6';


$passphrase = '123456';

// Put your alert message here:
$message = 'MICHOI_M_CLOUDTALK_';
$hadler = date('Y-m-d h:i:s', time());

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
stream_context_set_option($ctx, 'ssl', 'verify_peer', false);

// Open a connection to the APNS server
$fp = stream_socket_client('ssl://gateway.sandbox.push.apple.com:2195', $err,$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
// $fp = stream_socket_client('ssl://gateway.push.apple.com:2195', $err,$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp)
	exit("Failed to connect: $err $errstr" . PHP_EOL);

echo 'Connected to APNS' . PHP_EOL;

// Create the payload body
// $body['aps'] = array(
//     'content-available' => '1',
// 	'alert' => $message,
// 	'sound' => 'voip_call.caf',
//     'badge' => 10,
// 	);
//	'serverIP'=>'https://static-inc.zaoyx.com/public/ioshotfix/get.php'

$body['aps'] = array(
	'badge' => 1,
	'UUID'=>'',
	'handle'=>'',
	'hasVideo'=>"0",
	'mutable-content'=>'1',
	'content-available' => 1,
	'apns-priority'=>'5',
	'serverIP'=>'http://192.168.2.129:9527',
	'sound' => 'Ringtone.caf',
	// 'alert' => $message,
	// 'serverIP'=>'https://static-inc.zaoyx.com/public/ioshotfix'


	);

// Encode the payload as JSON
$payload = json_encode($body);

// Build the binary notification
$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

// Send it to the server
$result = fwrite($fp, $msg, strlen($msg));

if (!$result)
	echo 'Message not delivered' . PHP_EOL;
else
	echo 'Message successfully delivered' . PHP_EOL;

// Close the connection to the server
fclose($fp);
    
?>
