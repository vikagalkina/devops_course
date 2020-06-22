#!/bin/sh
# server LNMAP
apt-get update && apt-get upgrade -y

# paste site
rm -r /var/www/html
cp ./html /var/www/html

#install php-fpm
apt-get install -y php php-fpm
systemctl enable php7.2-fpm
systemctl start php7.2-fpm

# install nginx
apt-get install -y nginx
# delete default .conf folder nginx
rm -r cd /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/nginx.conf
# paste .conf in nginx
cp ./conf/nginx/conf.d/wordpress.conf /etc/nginx/conf.d/wordpress.conf
cp ./conf/nginx/nginx.conf /etc/nginx/nginx.conf
# restart && enabled nginx
systemctl restart nginx
