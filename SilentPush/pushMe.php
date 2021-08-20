



<?php

// Put your device token here (without spaces):
//ios 14

$deviceToken = 'c92866cb4c24b6cfedc773284f6b20348fe01ebc8b3a2d4d34fba3f3d8a3c2ec';
//adhoc
// $deviceToken = 'd2dc5ed03e7d5d900cafcfa7e47dafa0bbb809f8addb91de90257a518d67ea21';

//ios 11  
// $deviceToken = '108ce00ae4a02f8ce6204073b42a5b16c8c23b1e4eb5b3b127213fbd798c9c74';
//adhoc
// $deviceToken = 'a18314d1b6a347a53bede3943496bf2777ccab13c4e82e8012f97cdb60781cf9';


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
	"alert"=>"sss",
	'modify'=>'999',
	'sound'=>'default',
	// "badge" => 0,
    // "Priority" => 10

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
