FROM alpine:3.13

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
COPY run.sh /usr/local/bin/run.sh
COPY s6.d /etc/s6.d
COPY generate-certs /usr/local/bin/generate-certs
COPY letsencrypt-setup /usr/local/bin/letsencrypt-setup
COPY letsencrypt-renew /usr/local/bin/letsencrypt-renew
COPY periodic-certbot /etc/periodic/daily/certbot

RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/* /etc/periodic/daily/*
WORKDIR /etc/nginx
EXPOSE 80 443

LABEL description="Nginx proxy server with Let's Encrypt" \
      maintainer="ull <mart.maiste@gmail.com>"

CMD ["run.sh"]
