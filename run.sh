#!/bin/bash
DESTINATION=$1
PORT=$2
CHAT=$3
web_container_name="$DESTINATION"'_${WEB_HOST}'
db_container_name="$DESTINATION"'_${DB_HOST}'

# clone Odoo directory
git clone --depth=1 https://github.com/quangtv-vti/odoo-docker --branch odoo14 $DESTINATION
rm -rf $DESTINATION/.git
cp $DESTINATION/.env.template $DESTINATION/.env

# set permission
mkdir -p $DESTINATION/postgresql
sudo chmod -R 777 $DESTINATION
# config
if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
sudo sysctl -p
sed -i 's/${WEB_PORT}/'$PORT'/g' $DESTINATION/docker-compose.yml
sed -i 's/${CHAT_PORT}/'$CHAT'/g' $DESTINATION/docker-compose.yml

sed -i 's/${DB_HOST}/'$db_container_name'/g' $DESTINATION/docker-compose.yml
sed -i 's/${WEB_HOST}/'$web_container_name'/g' $DESTINATION/docker-compose.yml

# run Odoo
docker-compose -f $DESTINATION/docker-compose.yml up -d

echo 'Started Odoo @ http://localhost:'$PORT' | Master Password: quangnhung.odoo.com | Live chat port: '$CHAT
