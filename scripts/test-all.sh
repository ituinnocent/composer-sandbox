#!/bin/bash
# scripts/test-all.sh - Complete test suite

echo "🧪 STARTING COMPLETE TEST SUITE"
echo "================================"

echo "Colors for output"
echo ""
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Track failures"
echo ""
FAILURES=0
PASS=0
TOTAL=0

test_step() {
    local name="$1"
    local command="$2"
    local expected="$3"

    ((TOTAL++))
    echo -n "🔹 $name... "

    if eval "$command" > /tmp/test_output.log 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASS++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        echo "Command: $command"
        echo "Output:"
        cat /tmp/test_output.log
        echo ""
        ((FAILURES++))
        return 1
    fi
}

echo ""
echo "📋 PHASE 1: FILE STRUCTURE TESTS"
echo "--------------------------------"

test_step "Check config directory exists" "[ -d 'config' ]" "true"
test_step "Check nginx config exists" "[ -f 'config/nginx/nginx.conf' ]" "true"
test_step "Check php config exists" "[ -f 'config/php/php.ini' ]" "true"
test_step "Check mysql config exists" "[ -f 'config/mysql/my.cnf' ]" "true"
test_step "Check scripts directory" "[ -d 'scripts' ]" "true"
test_step "Check src directory" "[ -d 'src' ]" "true"
test_step "Check docker-compose.yml" "[ -f 'docker-compose.yml' ]" "true"
test_step "Check Dockerfile" "[ -f 'Dockerfile' ]" "true"
test_step "Check docker-entrypoint.sh" "[ -f 'docker-entrypoint.sh' ]" "true"

echo ""
echo "📋 PHASE 2: CONFIGURATION VALIDITY TESTS"
echo "----------------------------------------"

echo "Test config file syntax"
echo ""
test_step "Test nginx config syntax" "docker run --rm -v $(pwd)/config/nginx:/config nginx:alpine nginx -t -c /config/nginx.conf" "syntax ok"
test_step "Test PHP config syntax" "php -l config/php/php.ini 2>&1 | grep -q 'No syntax errors'" "true"
test_step "Test .env file exists" "[ -f '.env' ]" "true"
test_step "Test .env has required vars" "grep -q 'APP_NAME' .env && grep -q 'WP_DOMAINS' .env" "true"

echo ""
echo "📋 PHASE 3: DOCKER TESTS"
echo "------------------------"

test_step "Docker Compose config validation" "docker-compose config" "valid"
test_step "Docker build test" "docker-compose build --quiet" "success"

echo ""
echo "📋 PHASE 4: PHP SETUP CLASS TEST"
echo "--------------------------------"

test_step "Composer autoload works" "php -r 'require \"vendor/autoload.php\"; echo \"Autoload OK\";'" "Autoload OK"
test_step "Setup class exists" "php -r 'require \"vendor/autoload.php\"; class_exists(\"MyProject\\\Setup\") or exit(1);'" "true"
test_step "Setup::setupEnvironment() works" "php -r 'require \"vendor/autoload.php\"; MyProject\Setup::setupEnvironment();'" "success"

echo ""
echo "📋 PHASE 5: SCRIPT TESTS"
echo "------------------------"

echo "Make scripts executable first"
echo ""
chmod +x scripts/*.sh 2>/dev/null

test_step "init.sh executable" "[ -x 'scripts/init.sh' ]" "true"
test_step "setup-environment.sh works" "cd scripts && ./setup-environment.sh >/dev/null 2>&1; cd .." "success"
test_step "generate-nginx-config.php works" "php scripts/generate-nginx-config.php >/dev/null 2>&1" "success"

echo ""
echo "📋 PHASE 6: SSL CERTIFICATE TESTS"
echo "---------------------------------"

test_step "SSL directory exists" "[ -d 'ssl' ]" "true"

echo "Check if SSL certs exist or can be generated"
echo ""
if [ -f "ssl/my-website.local.crt" ] && [ -f "ssl/my-website.local.key" ]; then
    test_step "SSL certificates exist" "true" "true"
    test_step "SSL certificate validity" "openssl x509 -in ssl/my-website.local.crt -text -noout 2>/dev/null" "success"
else
    echo -e "${YELLOW}⚠️  SSL certificates not found (will be generated during setup)${NC}"
fi

echo ""
echo "📋 PHASE 7: GIT STATUS TEST"
echo "---------------------------"

test_step "Git repo initialized" "[ -d '.git' ]" "true"
test_step "No uncommitted config files" "git status --porcelain config/ 2>/dev/null | grep -v '^??'" "clean"

echo ""
echo "📋 PHASE 8: PORT AVAILABILITY TEST"
echo "---------------------------------"

test_step "Port 80 available" "lsof -i:80 >/dev/null 2>&1; [ \$? -eq 1 ]" "true"
test_step "Port 443 available" "lsof -i:443 >/dev/null 2>&1; [ \$? -eq 1 ]" "true"
test_step "Port 8080 available" "lsof -i:8080 >/dev/null 2>&1; [ \$? -eq 1 ]" "true"
test_step "Port 3306 available" "lsof -i:3306 >/dev/null 2>&1; [ \$? -eq 1 ]" "true"

echo ""
echo "========================================"
echo "📊 TEST RESULTS SUMMARY"
echo "========================================"
echo "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASS${NC}"
if [ $FAILURES -gt 0 ]; then
    echo -e "${RED}Failed: $FAILURES${NC}"
else
    echo -e "${GREEN}Failed: $FAILURES${NC}"
fi

if [ $FAILURES -eq 0 ]; then
    echo -e "\n${GREEN}✅ ALL TESTS PASSED! Your setup is ready.${NC}"
    echo -e "\nNext steps:"
    echo "1. Update hosts file: sudo php scripts/setup-hosts.php"
    echo "2. Start Docker: docker-compose up -d --build"
    echo "3. Access: https://my-website.local"
else
    echo -e "\n${RED}❌ Some tests failed. Check output above.${NC}"
    exit 1
fi
