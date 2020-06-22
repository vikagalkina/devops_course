#!/bin/sh
# server LNMAP
apt-get update && apt-get upgrade -y

# install nginx
apt-get install -y nginx
# delete default .conf folder nginx
rm -r cd /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/nginx.conf
# paste .conf in nginx
cp -r ./conf/nginx/conf.d/ /etc/nginx/conf.d/
cp ./conf/nginx/nginx.conf /etc/nginx/nginx.conf

#install php-fpm
apt-get install -y php php-fpm
systemctl enable php7.2-fpm
systemctl start php7.2-fpm

# restart && enabled nginx
systemctl restart nginx

# paste site
rm -r /var/www/html
cp -r ./html /var/www/html
