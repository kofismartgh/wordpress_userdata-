#!/bin/bash

# Dynamic User Data Script for WordPress Installation on AWS
# This template uses Terraform templatefile function for variable substitution

# Set variables from Terraform
PROJECT_NAME="${project_name}"
PROJECT_DOMAIN="${project_domain}"

# Log file for script execution
LOG_FILE="/var/log/wordpress_dynamic_install.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "Starting dynamic WordPress installation script..."
echo "PROJECT_NAME: $PROJECT_NAME"
echo "PROJECT_DOMAIN: $PROJECT_DOMAIN"

# Check if PROJECT_NAME and PROJECT_DOMAIN are provided
if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_DOMAIN" ]; then
    echo "Error: PROJECT_NAME and PROJECT_DOMAIN must be provided."
    exit 1
fi

# --- OS Detection ---
OS_ID="$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')"
OS_LIKE="$(grep ^ID_LIKE= /etc/os-release | cut -d= -f2 | tr -d '"')"

echo "Detected OS_ID: $OS_ID"
echo "Detected OS_LIKE: $OS_LIKE"

# --- OS-Specific Installation and Configuration ---
if [[ "$OS_ID" == "amzn" ]]; then
    echo "Detected Amazon Linux. Running Amazon Linux specific installation..."

    # Update system packages
    echo "Updating system packages..."
    sudo dnf update -y

    # Install Apache, PHP, and related modules
    echo "Installing Apache, PHP, and related modules..."
    sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Apache, PHP, and related modules on Amazon Linux."
        exit 1
    fi

    # Start and enable Apache
    echo "Starting and enabling Apache..."
    sudo systemctl start httpd
    sudo systemctl enable httpd
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start/enable Apache on Amazon Linux."
        exit 1
    fi

    # Install mod_ssl
    echo "Installing mod_ssl..."
    sudo dnf install -y mod_ssl
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install mod_ssl on Amazon Linux."
        exit 1
    fi

    # Restart Apache after mod_ssl installation
    echo "Restarting Apache..."
    sudo systemctl restart httpd
    if [ $? -ne 0 ]; then
        echo "Error: Failed to restart Apache after mod_ssl on Amazon Linux."
        exit 1
    fi

    # Install MariaDB client
    echo "Installing MariaDB client..."
    sudo dnf install -y mariadb105
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install MariaDB client on Amazon Linux."
        exit 1
    fi

    APACHE_CONF_DIR="/etc/httpd/conf.d"
    APACHE_USER="www-data"
    APACHE_GROUP="www-data"

elif [[ "$OS_ID" == "ubuntu" ]]; then
    echo "Detected Ubuntu. Running Ubuntu specific installation..."

    # Update system packages
    echo "Updating system packages..."
    sudo apt update -y

    # Install Apache, PHP, and related modules
    echo "Installing Apache, PHP, and related modules..."
    sudo apt install -y apache2 wget php libapache2-mod-php php-mysql php-json php-cli php-dev
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Apache, PHP, and related modules on Ubuntu."
        exit 1
    fi

    # Enable Apache modules
    echo "Enabling Apache modules..."
    sudo a2enmod php
    sudo a2enmod rewrite

    # Start and enable Apache
    echo "Starting and enabling Apache..."
    sudo systemctl start apache2
    sudo systemctl enable apache2
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start/enable Apache on Ubuntu."
        exit 1
    fi

    # Install MariaDB client
    echo "Installing MariaDB client..."
    sudo apt install -y mariadb-client
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install MariaDB client on Ubuntu."
        exit 1
    fi

    APACHE_CONF_DIR="/etc/apache2/sites-available"
    APACHE_USER="www-data"
    APACHE_GROUP="www-data"

elif [[ "$OS_ID" == "centos" || "$OS_LIKE" == *"rhel"* ]]; then
    echo "Detected CentOS/RHEL. Running CentOS/RHEL specific installation..."

    # Update system packages
    echo "Updating system packages..."
    sudo dnf update -y

    # Install Apache, PHP, and related modules
    echo "Installing Apache, PHP, and related modules..."
    sudo dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Apache, PHP, and related modules on CentOS/RHEL."
        exit 1
    fi

    # Start and enable Apache
    echo "Starting and enabling Apache..."
    sudo systemctl start httpd
    sudo systemctl enable httpd
    if [ $? -ne 0 ]; then
        echo "Error: Failed to start/enable Apache on CentOS/RHEL."
        exit 1
    fi

    # Install mod_ssl
    echo "Installing mod_ssl..."
    sudo dnf install -y mod_ssl
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install mod_ssl on CentOS/RHEL."
        exit 1
    fi

    # Restart Apache after mod_ssl installation
    echo "Restarting Apache..."
    sudo systemctl restart httpd
    if [ $? -ne 0 ]; then
        echo "Error: Failed to restart Apache after mod_ssl on CentOS/RHEL."
        exit 1
    fi

    # Install MariaDB client
    echo "Installing MariaDB client..."
    sudo dnf install -y mariadb
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install MariaDB client on CentOS/RHEL."
        exit 1
    fi

    APACHE_CONF_DIR="/etc/httpd/conf.d"
    APACHE_USER="apache"
    APACHE_GROUP="apache"

else
    echo "Error: Unsupported operating system detected. OS_ID: $OS_ID, OS_LIKE: $OS_LIKE"
    exit 1
fi

# --- WordPress Download and Setup ---
echo "Downloading and extracting WordPress..."
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to download WordPress."
    exit 1
fi
sudo tar -xzf latest.tar.gz
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract WordPress."
    exit 1
fi

# Setup WordPress directory
echo "Setting up WordPress directory..."
sudo mkdir -p /var/www/html/"$PROJECT_NAME"
sudo cp -r wordpress/* /var/www/html/"$PROJECT_NAME"/
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy WordPress files."
    exit 1
fi

# Set appropriate permissions for WordPress files
echo "Setting permissions for WordPress files..."
sudo chown -R "$APACHE_USER":"$APACHE_GROUP" /var/www/html/"$PROJECT_NAME"
sudo chmod -R 775 /var/www/html/"$PROJECT_NAME"

# --- Apache Virtual Host Configuration ---
echo "Configuring Apache Virtual Host..."
VHOST_CONF="$${APACHE_CONF_DIR}/$${PROJECT_DOMAIN}.conf"

if [[ "$OS_ID" == "ubuntu" ]]; then
    sudo bash -c "cat > \"$VHOST_CONF\" <<EOF
<VirtualHost *:80>
    ServerName $${PROJECT_DOMAIN}
    ServerAlias $${PROJECT_DOMAIN}
    DocumentRoot /var/www/html/$${PROJECT_NAME}
    ErrorLog /var/log/apache2/$${PROJECT_NAME}-error.log
    CustomLog /var/log/apache2/$${PROJECT_NAME}-access.log combined

    <Directory /var/www/html/$${PROJECT_NAME}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual host configuration on Ubuntu."
        exit 1
    fi

    # Enable the new virtual host
    echo "Enabling the new virtual host..."
    sudo a2ensite $${PROJECT_DOMAIN}.conf
    if [ $? -ne 0 ]; then
        echo "Error: Failed to enable virtual host on Ubuntu."
        exit 1
    fi

    # Disable default Apache virtual host
    echo "Disabling default Apache virtual host..."
    sudo a2dissite 000-default.conf

    # Restart Apache to apply Virtual Host changes
    echo "Restarting Apache to apply virtual host changes..."
    sudo systemctl restart apache2
    if [ $? -ne 0 ]; then
        echo "Error: Failed to restart Apache after vhost config on Ubuntu."
        exit 1
    fi
else # Amazon Linux and CentOS/RHEL
    sudo bash -c "cat > \"$VHOST_CONF\" <<EOF
<VirtualHost *:80>
    ServerName $${PROJECT_DOMAIN}
    ServerAlias $${PROJECT_DOMAIN}
    DocumentRoot /var/www/html/$${PROJECT_NAME}
    ErrorLog /var/log/httpd/$${PROJECT_NAME}-error.log
    CustomLog /var/log/httpd/$${PROJECT_NAME}-access.log combined

    <Directory /var/www/html/$${PROJECT_NAME}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual host configuration on Amazon Linux/CentOS/RHEL."
        exit 1
    fi

    # Restart Apache to apply Virtual Host changes
    echo "Restarting Apache to apply virtual host changes..."
    sudo systemctl restart httpd
    if [ $? -ne 0 ]; then
        echo "Error: Failed to restart Apache after vhost config on Amazon Linux/CentOS/RHEL."
        exit 1
    fi
fi

echo "Dynamic WordPress installation script completed successfully!"
echo "Please configure your DNS to point to this server's IP address."