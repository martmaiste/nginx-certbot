#!/bin/sh

${UPLOAD_MAX_SIZE:="10G"}
${CRON_PERIOD:="7d"}

if [ ! -e /etc/nginx/nginx.conf ]; then
  echo "nginx.conf not found, pulling from github"
  wget https://github.com/martmaiste/nginx-certbot/raw/master/nginx.conf -O /etc/nginx/nginx.conf
fi

sed -i -e "s/<UPLOAD_MAX_SIZE>/$UPLOAD_MAX_SIZE/g" /etc/nginx/nginx.conf \
       -e "s/<CRON_PERIOD>/$CRON_PERIOD/g" /etc/s6.d/cron/run

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
  if $(find $dir ! -user $UID -o ! -group $GID|egrep '.' -q); then
    echo "Updating permissions in $dir..."
    chown -R $UID:$GID $dir
  else
    echo "Permissions in $dir are correct."
  fi
done
echo "Done updating permissions."

exec su-exec $UID:$GID /bin/s6-svscan /etc/s6.d
