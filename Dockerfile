FROM alpine:3.6
ARG NGINX_VERSION=1.13.2
#ftp://ftp.openssl.org/source/
ARG OPENSSL_VERSION=1.0.2l
ARG HEADERES_MORE_NGINX_MODULE=0.32

RUN apk add --update \
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
    certbot \
    libtool \
    m4 \
    autoconf \
    automake \
  && rm -rf /var/cache/apk/*

RUN addgroup -g 9000 -S www-data \
  && adduser -u 9000 -D -S -G www-data www-data

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    -O latest_ngnix.gzipped
RUN wget ftp://ftp.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    -O latest_openssl.gzipped
RUN wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERES_MORE_NGINX_MODULE}.tar.gz \
    -O headers_more_nginx_module.gzipped

RUN mkdir -p /tmp/nginx \
    /tmp/headers-more-nginx-module \
    /tmp/modsecurity-nginx \
    /opt/.openssl \
    /opt/nginx-configuration

WORKDIR /opt
RUN git clone https://github.com/SpiderLabs/ModSecurity \
  && cd ModSecurity \
  && git checkout -b v3/master origin/v3/master \
  && sh build.sh \
  && git submodule init \
  && git submodule update \
  && ./configure \
  && make \
  && make install

WORKDIR /
RUN git clone https://github.com/SpiderLabs/ModSecurity-nginx.git /tmp/modsecurity-nginx
RUN tar --extract --file=headers_more_nginx_module.gzipped --strip-components=1 --directory=/tmp/headers-more-nginx-module
RUN tar --extract --file=latest_openssl.gzipped --strip-components=1 --directory=/opt/.openssl

WORKDIR /opt/.openssl
RUN ./config --prefix=/usr/local \
    --openssldir=/usr/local/open-ssl \
    threads \
    zlib \
  && make \
  && make test \
  && make install

WORKDIR /
RUN tar --extract --file=latest_ngnix.gzipped --strip-components=1 --directory=/tmp/nginx

WORKDIR /tmp/nginx
RUN ./configure --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/sbin/nginx \
    --conf-path=/opt/nginx-configuration/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/run/lock/subsys/nginx \
    --user=www-data --group=www-data \
    --add-module=/tmp/headers-more-nginx-module \
    --add-module=/tmp/modsecurity-nginx \
    --with-file-aio \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-openssl=/opt/.openssl \
    --with-stream \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
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
    --with-mail \
    --with-mail_ssl_module \
    --with-pcre-jit \
    --with-pcre \
    --with-debug \
  && make \
  && make install

RUN openssl dhparam -out /etc/dh2048.pem 2048

EXPOSE 80 443
WORKDIR /opt
ADD ./run/bootstrap.sh bootstrap.sh
RUN chmod u+x bootstrap.sh

ENTRYPOINT ["sh", "bootstrap.sh" ]
