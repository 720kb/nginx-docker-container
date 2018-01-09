FROM alpine:3.6
ARG NGINX_VERSION=1.13.2
#ftp://ftp.openssl.org/source/
ARG OPENSSL_VERSION=1.0.2l
ARG HEADERES_MORE_NGINX_MODULE=0.33
ARG MODSECURITY_MODULE=3.0.0
ARG MODSECURITY_NGINX_MODULE=1.0.0
ARG NAXSI_MODULE=0.55.3

RUN apk --no-cache add \
    curl-dev \
    wget \
    linux-headers \
    alpine-sdk \
    zlib-dev \
    pcre-dev \
    libxslt-dev \
    libxml2-dev \
    geoip-dev \
    perl \
    libaio-dev \
    acme-client \
    libtool \
    m4 \
    autoconf \
    automake \
    yajl-dev \
    gd-dev

RUN addgroup -g 9000 -S www-data \
  && adduser -u 9000 -D -S -G www-data www-data

RUN mkdir -p /tmp/nginx \
    /tmp/headers-more-nginx-module \
    /tmp/modsecurity-nginx \
    /tmp/naxsi \
    /opt/.openssl \
    /opt/nginx-configuration \
    /opt/modsecurity

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    -O latest_ngnix.gzipped
RUN wget ftp://ftp.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    -O latest_openssl.gzipped
RUN wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERES_MORE_NGINX_MODULE}.tar.gz \
    -O headers_more_nginx_module.gzipped
RUN wget https://github.com/SpiderLabs/ModSecurity/releases/download/v${MODSECURITY_MODULE}/modsecurity-v${MODSECURITY_MODULE}.tar.gz \
    -O modsecurity.gzipped
RUN wget https://github.com/SpiderLabs/ModSecurity-nginx/releases/download/v${MODSECURITY_NGINX_MODULE}/modsecurity-nginx-v${MODSECURITY_NGINX_MODULE}.tar.gz \
    -O modsecurity-nginx.gzipped
RUN wget https://github.com/nbs-system/naxsi/archive/${NAXSI_MODULE}.tar.gz \
    -O naxsi.gzipped

WORKDIR /
RUN tar --extract \
    --strip-components=1 \
    --file=latest_ngnix.gzipped --directory=/tmp/nginx \
  && tar --extract \
    --strip-components=1 \
    --file=modsecurity.gzipped --directory=/opt/modsecurity \
  && tar --extract \
    --strip-components=1 \
    --file=headers_more_nginx_module.gzipped --directory=/tmp/headers-more-nginx-module \
  && tar --extract \
    --strip-components=1 \
    --file=latest_openssl.gzipped --directory=/opt/.openssl \
  && tar --extract \
    --strip-components=1 \
    --file=modsecurity-nginx.gzipped --directory=/tmp/modsecurity-nginx \
  && tar --extract \
    --strip-components=1 \
    --file=naxsi.gzipped --directory=/tmp/naxsi \
  && rm -Rfv latest_ngnix.gzipped \
    latest_openssl.gzipped \
    headers_more_nginx_module.gzipped \
    modsecurity.gzipped \
    modsecurity-nginx.gzipped \
    naxsi.gzipped

WORKDIR /opt/modsecurity
RUN ./configure \
  && make -j 8 \
  && make install

WORKDIR /opt/.openssl
RUN ./config --prefix=/usr/local \
    --openssldir=/usr/local/open-ssl \
    threads \
    zlib \
  && make -j 8 \
  && make test \
  && make install

WORKDIR /tmp/nginx
RUN ./configure --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/sbin/nginx \
    --user=www-data --group=www-data \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/run/lock/subsys/nginx \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --conf-path=/opt/nginx-configuration/nginx.conf \
    --add-module=/tmp/headers-more-nginx-module \
    --add-module=/tmp/modsecurity-nginx \
    --add-module=/tmp/naxsi/naxsi_src \
    --with-openssl=/opt/.openssl \
    --with-file-aio \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_image_filter_module \
    --with-http_geoip_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_stub_status_module \
    --with-pcre-jit \
    --with-pcre \
    --with-debug \
    --with-mail \
    --with-mail_ssl_module \
    --without-mail_pop3_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
  && make -j 8 \
  && make install

RUN openssl dhparam -out /etc/dhparam.pem 4096
RUN mv /tmp/naxsi/naxsi_config/naxsi_core.rules /opt/naxsi_core.rules
RUN mkdir -p /var/lib/nginx/body /var/www/acme
RUN rm -Rfv /tmp/*

EXPOSE 80 443
WORKDIR /opt
ADD ./run/bootstrap.sh bootstrap.sh
ADD ./certbot certbot/
RUN chmod u+x bootstrap.sh

ENTRYPOINT ["sh", "bootstrap.sh" ]
