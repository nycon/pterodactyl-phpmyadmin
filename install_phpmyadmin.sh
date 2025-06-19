#!/usr/bin/env bash
set -euo pipefail

# Configuration
PMA_VERSION="5.2.1"
PMA_URL="https://files.phpmyadmin.net/phpMyAdmin/${PMA_VERSION}/phpMyAdmin-${PMA_VERSION}-all-languages.zip"
TARGET_DIR="/var/www/pterodactyl/public/phpmyadmin" # Adjust this path if needed
TMP_DIR="/tmp/phpmyadmin_install"
MYSQL_ROOT_PASSWORD="YourSecurePasswordHere" # Set your desired root password

echo "Preparing installation..."
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

echo "Downloading phpMyAdmin version $PMA_VERSION..."
wget -q "$PMA_URL"

echo "Installing required dependencies..."
sudo apt update
sudo apt install -y unzip

echo "Unzipping the archive..."
unzip "phpMyAdmin-${PMA_VERSION}-all-languages.zip"

echo "Creating target directory at: $TARGET_DIR"
sudo mkdir -p "$TARGET_DIR"

echo "Moving files to the target directory..."
sudo mv "phpMyAdmin-${PMA_VERSION}-all-languages"/* "$TARGET_DIR"/
sudo rm -rf "phpMyAdmin-${PMA_VERSION}-all-languages"
rm "phpMyAdmin-${PMA_VERSION}-all-languages.zip"

echo "Setting file permissions..."
sudo chown -R www-data:www-data "$TARGET_DIR"
sudo chmod -R 750 "$TARGET_DIR"

echo "Setting up configuration file..."
cd "$TARGET_DIR"
sudo mv config.sample.inc.php config.inc.php

# Generate a secure Blowfish secret
BLOWFISH=$(openssl rand -base64 32)
sudo sed -i "s/\$cfg\['blowfish_secret'\] = '';/\$cfg['blowfish_secret'] = '$BLOWFISH';/" config.inc.php

# Add TempDir if not already present
if ! grep -q "TempDir" config.inc.php; then
  echo "\$cfg['TempDir'] = '/tmp/';" | sudo tee -a config.inc.php > /dev/null
fi

echo "Checking MySQL root password status..."
IS_EMPTY=$(sudo mysql -sse "SELECT IF(authentication_string = '' OR authentication_string IS NULL, 'YES', 'NO') FROM mysql.user WHERE user = 'root' AND host = 'localhost';")

if [ "$IS_EMPTY" = "YES" ]; then
  echo "Setting MySQL root password..."
  sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('$MYSQL_ROOT_PASSWORD'); FLUSH PRIVILEGES;"
  echo "MySQL root password has been set."
else
  echo "MySQL root already has a password. Skipping."
fi

echo "Cleaning up temporary files..."
rm -rf "$TMP_DIR"

echo "phpMyAdmin has been successfully installed in: $TARGET_DIR"
echo "Access it via: https://your-domain.com/phpmyadmin (if properly linked in your web server)"
