#!/bin/bash

set -ex

apt update

#apt upgrade -y

apt install apache2 -y

cp ../load-balancer.conf /etc/apache2/sites-available

sed -i "s/$IP_HTTP_SERVER1/" /etc/apache/sites-available/load-balancer.conf
sed -i "s/$IP_HTTP_SERVER2/" /etc/apache/sites-available/load-balancer.conf

a2enmod proxy

a2enmod proxy_http

a2enmod proxy_balancer

systemctl restart apache2