<?php
// test-debug.php
require 'vendor/autoload.php';

echo "=== DEBUG MODE ===\n";

// Step 1: Check .env
echo "1. Checking .env...\n";
if (file_exists('.env')) {
    echo "   ✅ .env exists\n";
    $lines = file('.env');
    foreach ($lines as $line) {
        if (strpos($line, 'WP_DOMAINS') !== false) {
            echo "   ✅ WP_DOMAINS found: $line";
        }
    }
} else {
    echo "   ❌ .env missing\n";
}

// Step 2: Check SSL directory
echo "\n2. Checking SSL directory...\n";
$sslDir = __DIR__ . '/ssl';
echo "   Path: $sslDir\n";
echo "   Exists: " . (file_exists($sslDir) ? 'YES' : 'NO') . "\n";
echo "   Writable: " . (is_writable($sslDir) ? 'YES' : 'NO') . "\n";

// Step 3: Check OpenSSL
echo "\n3. Checking OpenSSL...\n";
echo "   openssl_pkey_new: " . (function_exists('openssl_pkey_new') ? '✅ Available' : '❌ Missing') . "\n";
echo "   openssl_csr_new: " . (function_exists('openssl_csr_new') ? '✅ Available' : '❌ Missing') . "\n";
echo "   openssl_csr_sign: " . (function_exists('openssl_csr_sign') ? '✅ Available' : '❌ Missing') . "\n";

// Test OpenSSL
echo "\n4. Testing OpenSSL functions...\n";
$key = @openssl_pkey_new(['private_key_bits' => 2048]);
if ($key === false) {
    echo "   ❌ openssl_pkey_new failed\n";
    while ($error = openssl_error_string()) {
        echo "      Error: $error\n";
    }
} else {
    echo "   ✅ openssl_pkey_new succeeded\n";
}

// Step 5: Try to run Setup
echo "\n5. Running Setup::setupEnvironment()...\n";
try {
    MyProject\Setup::setupEnvironment();
    echo "   ✅ Setup completed\n";
} catch (Exception $e) {
    echo "   ❌ Setup failed: " . $e->getMessage() . "\n";
}

// Step 6: Check results
echo "\n6. Checking results...\n";
if (file_exists("$sslDir/my-website.local.crt")) {
    echo "   ✅ SSL certificate created\n";
    echo "   Size: " . filesize("$sslDir/my-website.local.crt") . " bytes\n";
} else {
    echo "   ❌ SSL certificate NOT created\n";
    
    // List SSL directory
    echo "   SSL directory contents:\n";
    $files = glob("$sslDir/*");
    foreach ($files as $file) {
        echo "      - " . basename($file) . "\n";
    }
}
