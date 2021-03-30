#!/bin/sh

UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:="10G"}
CRON_PERIOD=${CRON_PERIOD:="7d"}

if [ ! -e /etc/nginx/nginx.conf ]; then
  echo "nginx.conf not found, pulling from github"
  wget https://github.com/martmaiste/nginx-certbot/raw/master/nginx.conf -O /etc/nginx/nginx.conf
fi

if [ ! -e /etc/nginx/mime.types ]; then
  echo "mime.types not found, pulling from github"
  wget https://raw.githubusercontent.com/nginx/nginx/master/conf/mime.types -O /etc/nginx/mime.types
fi

if grep -q UPLOAD_MAX_SIZE /etc/nginx/nginx.conf; then
  sed -i -e "s/<UPLOAD_MAX_SIZE>/$UPLOAD_MAX_SIZE/g" /etc/nginx/nginx.conf
fi

if grep -q CRON_PERIOD /etc/s6.d/cron/run; then
  sed -i -e "s/<CRON_PERIOD>/$CRON_PERIOD/g" /etc/s6.d/cron/run
fi

if [ ! -d /etc/letsencrypt/live/localhost ]; then
  echo "Creating directories for certificates..."
  mkdir -p /etc/letsencrypt/webrootauth /etc/letsencrypt/archive /etc/letsencrypt/live/localhost
fi

if [ ! -e /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
  echo "Generating self-signed certificates..."
  cd /etc/letsencrypt/live/localhost
  generate-certs
  cat cert.pem ca.pem > fullchain.pem && cat key.pem > privkey.pem
fi

echo "Updating permissions..."
for dir in /etc/nginx /var/log /var/lib/nginx /tmp /etc/s6.d; do
  if $(find $dir ! -user $UID -o ! -group $GID ! -perm -g=w |egrep '.' -q); then
    echo "Updating owners in $dir..."
    chown -R $UID:$GID $dir
  else
    echo "Owners in $dir are correct."
  fi
done

for dir in /var/lib/nginx/tmp /var/cache/nginx; do
  if $(find $dir ! -perm -g=rwx |egrep '.' -q); then
    echo "Updating permissions in $dir..."
    chmod -R g+rwx $dir
  else
    echo "Permissions in $dir are correct."
  fi
done

echo "Done updating permissions."

exec su-exec $UID:$GID /bin/s6-svscan /etc/s6.d
