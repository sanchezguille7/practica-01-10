#!/bin/bash

set -ex

apt update

#apt upgrade -y

source .env

snap install core
snap refresh core

apt remove certbot

snap install --classic certbot

ln -sf /snap/bin/certbot /usr/bin/certbot 

certbot --apache -m $CERTIFICATE_EMAIL --agree-tos --no-eff-email -d $CERTIFICATE_DOMAIN --non-interactive