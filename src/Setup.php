<?php
// src/Setup.php
namespace MyProject;

class Setup
{
    private static $envLoaded = false;

    public static function setupEnvironment(): void
    {
        echo "🔧 Setting up environment...\n";

        $rootDir = dirname(__DIR__, 2);
        $envFile = $rootDir . '/.env';

        // 1. Create .env if missing
        if (!file_exists($envFile)) {
            self::createEnvFile($envFile);
        }

        // 2. Load environment variables
        self::loadEnv();

        // 3. Create directories
        self::createDirectories();

        // 4. Generate SSL
        self::generateSSLCertificates();

        echo "✅ Environment setup complete!\n";
    }

    private static function loadEnv(): void
    {
        if (self::$envLoaded) {
            return;
        }

        $rootDir = dirname(__DIR__, 2);
        $envFile = $rootDir . '/.env';

        if (!file_exists($envFile)) {
            echo "⚠️  .env file not found\n";
            return;
        }

        // Simple manual parsing
        $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);

        foreach ($lines as $line) {
            $line = trim($line);

            // Skip comments and empty lines
            if (empty($line) || $line[0] === '#') {
                continue;
            }

            // Parse KEY=VALUE
            if (strpos($line, '=') !== false) {
                list($key, $value) = explode('=', $line, 2);
                $key = trim($key);
                $value = trim($value);

                // Remove surrounding quotes
                $value = trim($value, '"\'');

                // Set to $_ENV for PHP access
                $_ENV[$key] = $value;
                $_SERVER[$key] = $value;

                // Also put in environment for shell commands
                putenv("$key=$value");
            }
        }

        self::$envLoaded = true;
        echo "📁 Loaded environment variables from .env\n";
    }

    private static function createEnvFile(string $path): void
    {
        $content = <<<ENV
APP_NAME=my-website
WP_DOMAINS=my-website.local,www.my-website.local
WP_PRIMARY_DOMAIN=my-website.local
WP_ENV=development
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpresspassword
DB_ROOT_PASSWORD=rootpassword
SSL_COUNTRY=US
SSL_STATE=California
SSL_LOCALITY=San Francisco
SSL_ORGANIZATION=My Company
ENV;

        file_put_contents($path, $content);
        echo "📝 Created .env file\n";
    }

    private static function createDirectories(): void
    {
        $rootDir = dirname(__DIR__, 2);
        $dirs = [
            'web/wp-content/plugins',
            'web/wp-content/themes',
            'web/wp-content/uploads',
            'web/wp-content/mu-plugins',
            'web/wp-content/languages',
            'config/nginx/sites',
            'config/php',
            'config/mysql',
            'ssl',
            'logs/nginx',
            'logs/php',
            'logs/wordpress',
            'backups',
            'data/db',
            'scripts'
        ];

        foreach ($dirs as $dir) {
            $path = $rootDir . '/' . $dir;
            if (!file_exists($path)) {
                mkdir($path, 0755, true);
                echo "📁 Created directory: $dir\n";
            }
        }
    }

    private static function generateSSLCertificates(): void
    {
        self::loadEnv();

        $domains = explode(',', $_ENV['WP_DOMAINS'] ?? 'my-website.local');
        $primaryDomain = trim($domains[0]);

        $sslDir = dirname(__DIR__, 2) . '/ssl';
        $certFile = "$sslDir/$primaryDomain.crt";
        $keyFile = "$sslDir/$primaryDomain.key";

        if (file_exists($certFile) && file_exists($keyFile)) {
            echo "🔒 SSL certificates already exist for $primaryDomain\n";
            return;
        }

        echo "🔐 Generating SSL certificate for $primaryDomain...\n";

        // Create SSL config
        $sslConfig = [
            'digest_alg' => 'sha256',
            'private_key_bits' => 2048,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ];

        // Generate private key
        $privateKey = openssl_pkey_new($sslConfig);

        if ($privateKey === false) {
            echo "❌ Failed to generate private key. Trying alternative method...\n";
            self::generateSSLCertificatesAlternative($primaryDomain, $sslDir);
            return;
        }

        // Generate CSR
        $csr = openssl_csr_new([
            'countryName' => $_ENV['SSL_COUNTRY'] ?? 'US',
            'stateOrProvinceName' => $_ENV['SSL_STATE'] ?? 'California',
            'localityName' => $_ENV['SSL_LOCALITY'] ?? 'San Francisco',
            'organizationName' => $_ENV['SSL_ORGANIZATION'] ?? 'My Company',
            'commonName' => $primaryDomain,
        ], $privateKey);

        if ($csr === false) {
            echo "❌ Failed to generate CSR. Trying alternative method...\n";
            self::generateSSLCertificatesAlternative($primaryDomain, $sslDir);
            return;
        }

        // Generate self-signed certificate
        $cert = openssl_csr_sign($csr, null, $privateKey, 3650);

        if ($cert === false) {
            echo "❌ Failed to sign certificate. Trying alternative method...\n";
            self::generateSSLCertificatesAlternative($primaryDomain, $sslDir);
            return;
        }

        // Export files
        $certOut = '';
        $keyOut = '';

        openssl_x509_export($cert, $certOut);
        openssl_pkey_export($privateKey, $keyOut);

        file_put_contents($certFile, $certOut);
        file_put_contents($keyFile, $keyOut);

        chmod($keyFile, 0600);
        chmod($certFile, 0644);

        echo "✅ SSL certificates generated:\n";
        echo "   - $certFile\n";
        echo "   - $keyFile\n";
    }

    private static function generateSSLCertificatesAlternative(string $domain, string $sslDir): void
    {
        $certFile = "$sslDir/$domain.crt";
        $keyFile = "$sslDir/$domain.key";

        // Use openssl command line as fallback
        $cmd = "openssl req -x509 -nodes -days 365 -newkey rsa:2048 " .
            "-keyout '$keyFile' -out '$certFile' " .
            "-subj '/C=US/ST=California/L=San Francisco/O=My Organization/CN=$domain' 2>/dev/null";

        exec($cmd, $output, $returnCode);

        if ($returnCode === 0 && file_exists($certFile) && file_exists($keyFile)) {
            chmod($keyFile, 0600);
            echo "✅ SSL certificates generated (via openssl command)\n";
        } else {
            echo "⚠️  SSL generation failed. You'll need to generate certificates manually:\n";
            echo "    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \\\n";
            echo "      -keyout ssl/$domain.key \\\n";
            echo "      -out ssl/$domain.crt \\\n";
            echo "      -subj '/C=US/ST=State/L=City/O=Org/CN=$domain'\n";
        }
    }

    public static function getDomains(): array
    {
        self::loadEnv();

        $domains = [];

        // Get all domain environment variables
        $domainVars = ['WP_DOMAINS', 'DEV_DOMAINS', 'STAGING_DOMAINS'];

        foreach ($domainVars as $var) {
            if (!empty($_ENV[$var])) {
                $domainList = explode(',', $_ENV[$var]);
                $domains = array_merge($domains, array_map('trim', $domainList));
            }
        }

        return array_unique(array_filter($domains));
    }

    public static function getPrimaryDomain(): string
    {
        self::loadEnv();
        return $_ENV['WP_PRIMARY_DOMAIN'] ?? 'my-website.local';
    }

    public static function updateEnvironment(): void
    {
        echo "🔄 Updating environment...\n";
        self::$envLoaded = false; // Force reload
        self::loadEnv();
        echo "✅ Environment updated!\n";
    }
}
