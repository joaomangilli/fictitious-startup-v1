#!/bin/bash

APP_DIR="/opt/app"
USER="ssm-user"

sudo chown -R $USER:$USER $APP_DIR

sudo apt-get update
sudo apt-get install -y python3-pip python3-venv postgresql postgresql-contrib nginx

sudo systemctl start postgresql
sudo systemctl enable postgresql

source $APP_DIR/secrets.sh

sudo -i -u postgres psql <<EOF
CREATE DATABASE mvp;
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
ALTER ROLE $DB_USER SET client_encoding TO 'utf8';
ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';
ALTER ROLE $DB_USER SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE mvp TO $DB_USER;
EOF

sed -i "s|REPLACE_SECRET_KEY|$SECRET_KEY|g" $APP_DIR/cloudtalents/settings.py
sed -i "s|REPLACE_DATABASE_USER|$DB_USER|g" $APP_DIR/cloudtalents/settings.py
sed -i "s|REPLACE_DATABASE_PASSWORD|$DB_PASSWORD|g" $APP_DIR/cloudtalents/settings.py

python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install -r $APP_DIR/requirements.txt

python3 $APP_DIR/manage.py makemigrations
python3 $APP_DIR/manage.py migrate

cat > /tmp/gunicorn.service <<EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
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
