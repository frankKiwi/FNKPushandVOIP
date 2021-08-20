



<?php

// Put your device token here (without spaces):
//ios 14

$deviceToken = 'a2f1f16160d9ba6334b487728cd77cc98e461fc80b4d6a2e00804ffae1dad9d6';
//adhoc
// $deviceToken = '1093b614d965b24e6c8cebe7df9b4bab141af9c4ca30910f212c1e11594fd6a8';

//ios 11  
$deviceToken = 'f1bf2191e6993ea20b071d5e8646d9bc147781f670eb0bea6aee6ba03cac770c';
//adhoc
// $deviceToken = '478fe5d5fcd531434fe36baf4ebc34493786c114b2e979842a61a022838a1067';


$passphrase = '123456';
// $passphrase = '';


// Put your alert message here:
$message = 'MICHOI_M_CLOUDTALK_';

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
stream_context_set_option($ctx, 'ssl', 'verify_peer', false);

// Open a connection to the APNS server
$fp = stream_socket_client('ssl://gateway.sandbox.push.apple.com:2195', $err,$errstr, 60, STREAM_CLIENT_CONNECT, $ctx);
// $fp = stream_socket_client('ssl://gateway.push.apple.com:2195', $err,$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp)
	exit("Failed to connect: $err $errstr" . PHP_EOL);

echo 'Connected to APNS' . PHP_EOL;


$body['aps'] = array(
	'badge' => 1,
	'mutable-content'=>'1',
	'content-available' => '1',
	'apns-priority'=>'5',
	"alert"=>array(
		"title"=>"早游戏",
		"subtitle"=>"",
		"body"=>""
	),
	// 'modify'=>'999',
	// 'sound'=>'default'

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
