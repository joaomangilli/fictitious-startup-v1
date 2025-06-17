#!/bin/bash

APP_DIR="/opt/app"
USER="ubuntu"

sudo chown -R $USER:$USER $APP_DIR

sudo apt-get update
sudo apt-get install -y python3-pip python3.10-venv nginx

python3 -m venv venv
source venv/bin/activate

ls /tmp
ls $APP_DIR

pip install --upgrade pip
pip install -r $APP_DIR/requirements.txt

cat > /tmp/gunicorn.service <<EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
Environment="AWS_DEFAULT_REGION=us-east-2"
User=$USER
Group=www-data
WorkingDirectory=$APP_DIR
ExecStart=$PWD/venv/bin/gunicorn \
          --workers 3 \
          --bind unix:/tmp/gunicorn.sock \
          cloudtalents.wsgi:application

[Install]
WantedBy=multi-user.target
EOF
sudo mv /tmp/gunicorn.service /etc/systemd/system/gunicorn.service

sudo systemctl start gunicorn
sudo systemctl enable gunicorn

sudo rm /etc/nginx/sites-enabled/default
cat > /tmp/nginx_config <<EOF
server {
    listen 80;
    server_name your_domain_or_IP;

    location = /favicon.ico { access_log off; log_not_found off; }

    location /media/ {
        root $APP_DIR/;
    }

    location / {
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_pass http://unix:/tmp/gunicorn.sock;
    }
}
EOF
sudo mv /tmp/nginx_config /etc/nginx/sites-available/cloudtalents

sudo ln -s /etc/nginx/sites-available/cloudtalents /etc/nginx/sites-enabled
sudo nginx -t

sudo systemctl restart nginx

sudo ufw allow 'Nginx Full'

echo "Django application setup complete!"
