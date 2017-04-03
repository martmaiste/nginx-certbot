## nginx reverse proxy with Let's Encrypt support

## Synopsis

Nginx reverse proxy with Let's Encrypt support.
At install time, a self-signed SSL certificate will be generated. This is required for the nginx to start with default https configuration.

## Installation

DOMAIN and EMAIL variables are optional and they are used for generating Let's Encrypt certificates.

```
git clone https://github.com/martmaiste/nginx-certbot-docker.git
docker build -t nginx nginx-certbot-docker
docker run --name nginx -p 80:80 -p 443:443 \
       -e DOMAIN=localhost \
       -e EMAIL=hostmaster@localhost \
       -t nginx
```

Generating Let's Encrypt certificate

```
docker exec -ti nginx letsencrypt-setup
```

Renewing Let's Encrypt certificate manually

```
docker exec -ti nginx letsencrypt-renew
```

## Credits

[Nextcloud 11 Dockerfile by Wonderfall](https://github.com/Wonderfall/dockerfiles/tree/master/nextcloud/11.0)

[Self Signed SSL Certificate Generator by paulczar](https://github.com/paulczar/omgwtfssl)
