#!/bin/bash

$1=$user
$2=$user_password
$3=$root_password
$4=$database_name

echo "GRANT ALL PRIVILEGES ON ${database_name}.* TO '${user}'@'%'IDENTIFIED BY '${user_password}';" | mysql -u root -p${root_password}
