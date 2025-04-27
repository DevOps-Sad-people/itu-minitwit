
#!/bin/bash
# This script sets up SSL for a domain using Certbot and Nginx on a fresh Ubuntu server
# Usage: ./upgrade-to-ssl.sh <domain> <port>
# Example: ./upgrade-to-ssl.sh example.com 3000

# Write out help message if no arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <domain> <port>"
    echo "Example: $0 example.com 3000"
    exit 1
fi

DOMAIN=$1
PORT=$2

# Setup CERTBOT for SSL
# This script is intended to be run on a fresh Ubuntu 20.04 server
sudo snap install core; sudo snap refresh core
sudo apt remove certbot
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Setup firewall
ufw enable
ufw allow OpenSSH

# Allow existing connections to DOMAIN
ufw allow $PORT/tcp
ufw allow $PORT/udp

# Install Nginx
sudo apt update
sudo apt install nginx

# Setup nginx config
# /etc/nginx/sites-available/$DOMAIN
echo "server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    # This location allows Let's Encrypt HTTP verification
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}" | sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null

sudo mkdir -p /var/www/html/.well-known/acme-challenge
sudo chmod -R 755 /var/www/html

sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

sudo nginx -t
sudo systemctl reload nginx

sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'

# Pause user and ensure that the domain is pointed to the server.
# Get the current server's public IP address
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "Your server's public IP address is: $PUBLIC_IP"
echo "Please ensure that your domain is pointed to this server before continuing."
echo "$DOMAIN => $PUBLIC_IP"
echo "www.$DOMAIN => $PUBLIC_IP"
echo "If you have already done this, press enter to continue. Otherwise do it, and wait a few minutes."
read -p "Press enter to continue"

sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN