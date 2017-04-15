## Nginx reverse proxy with Let's Encrypt support

## Synopsis

Nginx reverse proxy with Let's Encrypt support.

At the install time, a self-signed SSL certificate is generated. This is required for the nginx to start with default https configuration.

Default nginx configuration redirects all http requests (except Let's Encrypt challenge) to https.

https requests are proxied to upstream server on port 8080.

## Installation and usage

DOMAIN and EMAIL variables are optional and they are used for generating Let's Encrypt certificate.

Either pull the image directly from Docker Hub:
```
docker pull martmaiste/nginx-certbot

```
Or build it locally:
```
git clone https://github.com/martmaiste/nginx-certbot.git
docker build -t nginx nginx-certbot
```

Run the container:
```
docker run -d --name nginx -p 80:80 -p 443:443 \
       -e DOMAIN=localhost \
       -e EMAIL=hostmaster@localhost \
       -t nginx
```

Generate a new Let's Encrypt certificate

Cron daemon tries to renew the certificate once every 7 days.

```
docker exec -ti nginx letsencrypt-setup
```

Renew Let's Encrypt certificate manually

```
docker exec -ti nginx letsencrypt-renew
```

Edit nginx.conf

```
docker exec -ti nginx vi /etc/nginx/nginx.conf
```

Reload nginx configuration

```
docker exec -ti nginx nginx -s reload
```

## Credits

[Nextcloud 11 Dockerfile by Wonderfall](https://github.com/Wonderfall/dockerfiles/tree/master/nextcloud/11.0)

[Self Signed SSL Certificate Generator by paulczar](https://github.com/paulczar/omgwtfssl)
