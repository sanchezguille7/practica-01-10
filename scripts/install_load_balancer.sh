#!/bin/bash

set -ex

apt update

#apt upgrade -y

apt install apache2 -y

cp /home/ubuntu/practica-01-10/conf/load-balancer.conf /etc/apache2/sites-available

#sed -i "s/$IP_HTTP_SERVER1/" /etc/apache/sites-available/load-balancer.conf
#sed -i "s/$IP_HTTP_SERVER2/" /etc/apache/sites-available/load-balancer.conf

a2enmod proxy

a2enmod proxy_http

a2enmod proxy_balancer

a2enmod lbmethod_byrequests

systemctl restart apache2

a2ensite load-balancer.conf 

a2dissite 000-default.conf 

apache2ctl -S

systemctl restart apache2