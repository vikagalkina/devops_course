#!/bin/sh
# server LNMAP
apt-get update && apt-get upgrade -y

#install php-fpm
apt-get install -y php php-fpm
systemctl enable php7.3-fpm
systemctl start php7.3-fpm

# install nginx
apt-get install -y nginx
# delete default .conf folder nginx
rm -r cd /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/nginx.conf
# paste .conf in nginx
cp ./conf/nginx/conf.d/wordpress.conf /etc/nginx/conf.d/wordpress.conf
cp ./conf/nginx/nginx.conf /etc/nginx/nginx.conf
