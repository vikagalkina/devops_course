#!/bin/sh
printf "
#######################################################################
#                     LAMP deployment script                          #
#######################################################################
"

read -p 'Enter db name: ' db_name

read -p 'Enter db user: ' db_user

read -sp 'Enter db user password: ' db_user_password

echo Summary:
echo db name: $db_name
echo db user: $db_user


# Update packages
apt-get update
read -p 'Do you want to upgrade packages? Type \'y\' if yes: ' need_upgrade
if [ $need_upgrade == 'y' ]
then
  apt-get upgrade -y
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
echo To import db from file put your file to conf/mysql dir with filename backup.sql
read -p 'Do you want to create new db or import from sql? Type \'n\' for new or \'i\' for import: ' db_create_option
if [ $db_create_option == 'n' ]
then
  mysql -u root < .conf/mysql/base_install.sql
elif [ $db_create_option == 'i' ]
then
  FILE=/etc/resolv.conf
  if [ -f '.conf/mysql/backup.sql' ]
  then
    mysql -u root < .conf/mysql/backup.sql
  else
    echo There no file backup.sql in .conf/mysql/ directory!!!
  fi
else
  echo Wrong option!!!
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