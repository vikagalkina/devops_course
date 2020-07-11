#!/bin/sh
printf "
#######################################################################
#                     LAMP deployment script                          #
#######################################################################
"

if ! [ $(id -u) = 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

# Read user info for db
read -p 'Enter db name: ' db_name

read -p 'Enter db user: ' db_user

read -sp 'Enter db user password: ' db_user_password
echo
read -sp 'Enter db root password: ' db_root_password
echo
echo Summary:
echo db name: $db_name
echo db user: $db_user

export DB_NAME=$db_name
export DB_USER=$db_user
export DB_USER_PASSWORD=$db_user_password
export DB_ROOT_PASSWORD=$db_root_password


# Update packages
apt-get update
read -p 'Do you want to upgrade packages? Type "y" if yes: ' need_upgrade
if [ $need_upgrade == 'y' ]
then
  apt-get upgrade -y
else
  echo System will not be upgraded
fi

# install nginx
apt-get install -y nginx

# delete default .conf folder nginx
rm -r /etc/nginx/sites-available /etc/nginx/sites-enabled

# paste .conf in nginx
cp -r ./conf/nginx/conf.d/ /etc/nginx/
cp ./conf/nginx/nginx.conf /etc/nginx/nginx.conf


# install php
apt install php7.4-fpm php7.4-common php7.4-mysql php7.4-gmp php7.4-curl php7.4-intl php7.4-mbstring php7.4-xmlrpc php7.4-gd php7.4-xml php7.4-cli php7.4-zip -y

# enable php mod
a2enmod php7.4

# enable and start php
systemctl enable php7.4-fpm
systemctl start php7.4-fpm

# install apache
apt-get install -y apache2 libapache2-mod-php
cp ./conf/apache/ports.conf /etc/apache2/ports.conf
cp ./conf/apache/apache2.conf /etc/apache2/apache2.conf
cp ./conf/apache/dir.conf /etc/apache2/mods-available/dir.conf


# install MySQL
apt install mysql-server

echo You can create new db for wordpress or import db from sql file.
read -p 'Do you want to create new db or import from sql? Type "n" for new or "i" for import: ' db_create_option

conf/mysql/base_install.sh

if [ $db_create_option == 'n' ]
then
  echo Empty db installed!
elif [ $db_create_option == 'i' ]
then
  read -p 'Enter remote host address: ' remote_host
  read -p 'Enter remote db user: ' remote_db_user
  read -p 'Enter password for db user: ' remote_db_password
  read -p 'Enter db name: ' remote_db_name

  mysqldump -h $remote_host -u $remote_db_user -p$remote_db_password $remote_db_name > conf/mysql/backup.sql

  if [ -f 'conf/mysql/backup.sql' ]
  then
    mysql -u root -p$db_root_password $db_name < conf/mysql/backup.sql
    rm conf/mysql/backup.sql
  else
    echo There no file backup.sql in conf/mysql/ directory!!!
    exit 1
  fi
else
  echo Wrong option!!!
  exit 1
fi




# paste site
rm -r /var/www/wordpress
cp -r ./wordpress /var/www/wordpress
sudo chown -R www-data:www-data /var/www/wordpress/
sudo chmod -R 755 /var/www/wordpress/

# enable and start nginx
systemctl enable nginx
systemctl start nginx

# enable and start apache
sudo systemctl enable apache2
sudo systemctl start apache2
