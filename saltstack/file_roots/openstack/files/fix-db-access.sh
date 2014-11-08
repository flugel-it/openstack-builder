#!/bin/bash


user=$1
user_password=$2
root_password=$3
database_name=$4
host=$5

[[ $host == '' ]] && host=controller

echo "GRANT ALL PRIVILEGES ON ${database_name}.* TO '${user}'@'%' IDENTIFIED BY '${user_password}';" | mysql -h ${host} -u root -p${root_password} -vv && \
	        touch /etc/salt/.${user}-access-fixed

