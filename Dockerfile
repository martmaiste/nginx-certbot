FROM alpine:3.7

ENV UID=0 GID=0 \
    NGINX_VERSION=nginx-1.8.0 \
    UPLOAD_MAX_SIZE=10G \
    CRON_PERIOD=7d \
    EMAIL=hostmaster@localhost \
    DOMAIN=localhost
RUN addgroup -S nginx \
 && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
 && apk -U upgrade && apk add \
    bash \
    libssl1.0 \
    openssl \
    certbot \   
    s6 \
    ca-certificates \
    su-exec \
    tzdata \
 && apk --update add openssl-dev pcre-dev zlib-dev wget build-base && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz && \
    tar -zxvf ngx_cache_purge-2.3.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --sbin-path=/usr/sbin/nginx \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --add-module=/tmp/src/ngx_cache_purge-2.3 && \
    make && \
    make install && \
    apk del build-base && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/* /tmp/* /root/.gnupg

COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /usr/local/bin/run.sh
COPY s6.d /etc/s6.d
COPY generate-certs /usr/local/bin/generate-certs
COPY letsencrypt-setup /usr/local/bin/letsencrypt-setup
COPY letsencrypt-renew /usr/local/bin/letsencrypt-renew

RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*

EXPOSE 80 443

LABEL description="Nginx proxy server with Let's Encrypt" \
      maintainer="ull <mart.maiste@gmail.com>"

CMD ["run.sh"]
