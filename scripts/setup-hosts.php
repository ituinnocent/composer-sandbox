#!/usr/bin/env php
<?php
// scripts/setup-hosts.php

require_once __DIR__ . '/../vendor/autoload.php';

use MyProject\Setup;

echo "📝 Updating /etc/hosts...\n";

$domains = Setup::getDomains();

if (empty($domains)) {
    echo "❌ No domains found\n";
    exit(1);
}

echo "🌐 Domains: " . implode(', ', $domains) . "\n";

$hostsFile = '/etc/hosts';
$backupFile = $hostsFile . '.backup.' . date('YmdHis');

// Backup
copy($hostsFile, $backupFile);

// Read and update
$lines = file($hostsFile);
$newLines = [];
$skipNext = false;

foreach ($lines as $line) {
    $trimmed = trim($line);

    // Skip our previous entries
    if (strpos($trimmed, '# Docker: my-website') === 0) {
        $skipNext = true;
        continue;
    }

    if ($skipNext) {
        // Check if this line contains our domains
        $hasDomain = false;
        foreach ($domains as $domain) {
            if (strpos($line, $domain) !== false) {
                $hasDomain = true;
                break;
            }
        }
        if ($hasDomain) {
            $skipNext = false;
            continue;
        }
        $skipNext = false;
    }

    $newLines[] = rtrim($line);
}

// Add our entries
$newLines[] = "";
$newLines[] = "# Docker: my-website";
$newLines[] = "127.0.0.1\t" . implode(' ', $domains);
$newLines[] = "";

file_put_contents($hostsFile, implode("\n", $newLines));

echo "✅ /etc/hosts updated!\n";
echo "📋 Backup: $backupFile\n";
echo "\nAccess:\n";
foreach ($domains as $domain) {
    echo "  https://$domain\n";
}
