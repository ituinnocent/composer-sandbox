#!/usr/bin/env php
<?php

require_once __DIR__ . '/../vendor/autoload.php';

use MyProject\Setup;

echo "🌐 Generating Nginx configuration...\n";

$domains = Setup::getDomains();
$primaryDomain = Setup::getPrimaryDomain();

if (empty($domains)) {
    echo "❌ No domains found\n";
    exit(1);
}

echo "📋 Domains: " . implode(', ', $domains) . "\n";

$config = <<<NGINX
# Auto-generated Nginx configuration
server {
    listen 80;
    listen [::]:80;
    server_name {DOMAINS};
    
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name {DOMAINS};
    
    ssl_certificate /etc/ssl/{PRIMARY_DOMAIN}.crt;
    ssl_certificate_key /etc/ssl/{PRIMARY_DOMAIN}.key;
    
    root /var/www/html/web;
    index index.php;
    
    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }
    
    location ~ \.php\$ {
        fastcgi_pass wordpress:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
NGINX;

$config = str_replace(
    ['{DOMAINS}', '{PRIMARY_DOMAIN}'],
    [implode(' ', $domains), $primaryDomain],
    $config
);

$configDir = dirname(__DIR__) . '/config/nginx/sites';
if (!file_exists($configDir)) {
    mkdir($configDir, 0755, true);
}

$configFile = $configDir . '/' . $primaryDomain . '.conf';
file_put_contents($configFile, $config);

echo "✅ Nginx config: $configFile\n";
