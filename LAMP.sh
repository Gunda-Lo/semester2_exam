#!/bin/bash

# Define variables
GITHUB_REPO="https://github.com/laravel/laravel.git"
DB_USER="segun"
DB_PASSWORD="segunda"
DB_NAME="Amapiano"
php_ini_file="/etc/php/8.2/apache2/php.ini"

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Check if a file or directory exists
file_exists() {
    [ -e "$1" ]
}

# Update and upgrade system packages
log "Updating APT packages and upgrading to the latest patches..."
sudo apt update -y
sudo apt upgrade -y

# Install Apache
log "Installing Apache2..."
sudo apt install -y apache2

# Enable firewall rules
log "Adding firewall rules for Apache..."
sudo ufw allow 'Apache'
echo "y" | sudo ufw enable

# Install PHP 8.2 and its modules if not already installed
if ! command_exists php8.2; then
    log "Installing PHP 8.2 and modules..."
    sudo apt install -y software-properties-common apt-transport-https
    sudo add-apt-repository ppa:ondrej/php -y
    sudo apt update
    sudo apt install -y php8.2-fpm libapache2-mod-php8.2 php8.2-common php8.2-mysql php8.2-xml php8.2-xmlrpc php8.2-curl php8.2-gd php8.2-imagick php8.2-cli php8.2-dev php8.2-imap php8.2-mbstring php8.2-opcache php8.2-soap php8.2-zip php8.2-intl php8.2-bcmath
fi

# Configure php
log "Configuring PHP..."
if file_exists "$php_ini_file"; then
    # Use sed to edit the php.ini file
    sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' "$php_ini_file"
    log "cgi.fix_pathinfo set to 0 in php.ini"
else
    log "php.ini file not found at $php_ini_file"
fi

# Restart Apache
log "Restarting Apache..."
sudo systemctl restart apache2

# Install required packages (Git, Composer, and other dependencies) if not already installed
if ! command_exists git; then
    log "Installing Git..."
    sudo apt install -y git
fi

# Configure Apache to serve the PHP application
log "Configuring Apache to serve the PHP application..."
echo '<VirtualHost *:80>
    ServerAdmin segeboi@gmail.com
    ServerName 192.168.56.5
    DocumentRoot /var/www/html/laravel//public

    <Directory /var/www/html/laravel/>
        Options Indexes MultiViews FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/laravel.conf

sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

# Activate the laravel virtual host
sudo a2enmod rewrite
sudo a2ensite laravel.conf

# Restart Apache
log "Restarting Apache..."
sudo systemctl reload apache2

# Create and navigate to the desired directory
log "Creating and navigating to /var/www/html/laravel/..."
sudo mkdir -p /var/www/html/laravel
cd /var/www/html/laravel

# Clone the Laravel project from GitHub
log "Cloning the Laravel project from GitHub..."
sudo git clone "$GITHUB_REPO" .

# Install Laravel's dependencies using Composer
log "Installing Laravel dependencies using Composer..."
composer install --no-dev

# Set permissions for the Laravel project directory
log "Setting permissions for /var/www/html/laravel/..."
sudo chown -R www-data:www-data /var/www/html/laravel
sudo chmod -R 775 /var/www/html/laravel//storage
sudo chmod -R 775 /var/www/html/laravel//bootstrap/cache

log "Laravel project cloned, permissions have been set, and directories have been configured."

# Copy the .env example file and generate the application key
sudo cp /var/www/html/laravel//.env.example /var/www/html/laravel/.env
sudo php /var/www/html/laravel//artisan key:generate

# Configure MySQL
log "Configuring MySQL..."
sudo mysql -e "CREATE DATABASE $DB_NAME;"
sudo mysql -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES"

# Use sed to replace the values in the .env file
log "Replacing values in .env file..."
sudo sed -i 's/^APP_ENV=.*/APP_ENV=production/' /var/www/html/laravel/.env
sudo sed -i 's/^APP_DEBUG=.*/APP_DEBUG=false/' /var/www/html/laravel/.env
sudo sed -i 's/^APP_URL=.*/APP_URL=http:\/\/your_domain_or_ip/' /var/www/html/laravel/.env
sudo sed -i 's/^DB_HOST=.*/DB_HOST=localhost/' /var/www/html/laravel/.env
sudo sed -i 's/^DB_DATABASE=.*/DB_DATABASE='$DB_NAME'/' /var/www/html/laravel/.env
sudo sed -i 's/^DB_USERNAME=.*/DB_USERNAME='$DB_USER'/' /var/www/html/laravel/.env
sudo sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD='$DB_PASSWORD'/' /var/www/html/laravel/.env
sudo sed -i 's/^MEMCACHED_HOST=.*/MEMCACHED_HOST=127.0.0.1/' /var/www/html/laravel/.env
sudo sed -i 's/^REDIS_HOST=.*/REDIS_HOST=127.0.0.1/' /var/www/html/laravel/.env
sudo sed -i 's/^MAIL_MAILER=.*/MAIL_MAILER=smtp/' /var/www/html/laravel/.env
sudo sed -i 's/^MAIL_HOST=.*/MAIL_HOST=smtp.example.com/' /var/www/html/laravel/.env
sudo sed -i 's/^MAIL_PORT=.*/MAIL_PORT=587/' /var/www/html/laravel/.env
sudo sed -i 's/^MAIL_USERNAME=.*/MAIL_USERNAME=youremail@example.com/' /var/www/html/laravel/.env
sudo sed -i 's/^MAIL_PASSWORD=.*/MAIL_PASSWORD=your_email_password/' /var/www/html/laravel/.env

log "Values replaced in .env file"

# Cache the configuration
cd /var/www/html/laravel
sudo php artisan config:cache

# Run database migrations
sudo php artisan migrate

log "LAMP stack setup and Laravel installation is complete."