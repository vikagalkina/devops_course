mysql -u root -p$db_root_password -e "CREATE DATABASE $db_name;"
mysql -u root -p$db_root_password -e "CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_user_password';"
mysql -u root -p$db_root_password -e "GRANT ALL PRIVILEGES ON $db_user.* TO '$db_user'@'localhost';"
mysql -u root -p$db_root_password -e "FLUSH PRIVILEGES;"

