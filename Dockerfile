FROM alpine:3.23

ENV UID=0 GID=0 \
    UPLOAD_MAX_SIZE=10G \
    CRON_PERIOD=7d \
    EMAIL=hostmaster@localhost \
    DOMAIN=localhost

RUN addgroup -S nginx \
 && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
 && apk -U upgrade && apk add \
    bash \
    openssl \
    certbot \   
    nginx \
    nginx-mod-http-cache-purge \
    nginx-mod-http-headers-more \
    s6 \
    ca-certificates \
    su-exec \
    tzdata \
    logrotate \
 && rm -rf /var/cache/apk/* /tmp/* /root/.gnupg

COPY nginx.conf /etc/nginx/nginx.conf
COPY s6.d /etc/s6.d
ADD  run.sh letsencrypt-renew letsencrypt-setup generate-certs /usr/local/bin/
ADD  periodic-certbot /etc/periodic/daily/certbot
ADD  logrotate-nginx /etc/logrotate.d/nginx

RUN rm -rf /etc/nginx/http.d \ 
 && mkdir /etc/nginx/conf.d \
 && chmod +x,go-w /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/* /etc/periodic/daily/* \
 && chmod go-w /etc/logrotate.d/*

WORKDIR /etc/nginx

EXPOSE 80 443

LABEL description="Nginx proxy server with Let's Encrypt" \
      maintainer="ull <mart.maiste@gmail.com>"

CMD ["run.sh"]
