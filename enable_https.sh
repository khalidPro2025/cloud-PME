#!/bin/bash

DOMAIN="cloud-pme.tech"
EMAIL="admin@cloud-pme.tech"

docker-compose up -d nginx

docker-compose run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  -d $DOMAIN

docker-compose restart nginx

echo "HTTPS activé pour https://$DOMAIN"
