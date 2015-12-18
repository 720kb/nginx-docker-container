FROM ubuntu
MAINTAINER Dario Andrei <wouldgo84@gmail.com>

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y wget build-essential zlib1g-dev libpcre3-dev libxslt1-dev libxml2-dev libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libperl-dev

RUN mkdir -p /tmp/nginx /tmp/openssl && \
mkdir -p /opt/nginx-configuration && \
wget http://nginx.org/download/nginx-$(wget -O - http://nginx.org/download/ | \
  grep -o -P '<a href="nginx-.+.tar.gz">' | \
  sed -re's/<a href="nginx-(.+)\.tar.gz">/\1/g' | \
  tail -1).tar.gz -O latest_ngnix.gzipped && \
wget $(wget -O - ftp://ftp.openssl.org/source/ | \
  grep -o -P 'ftp://ftp\.openssl\.org:21/source/openssl-1\.0\.2\w.*.tar.gz' | \
  sed -re's/(ftp:\/\/ftp\.openssl\.org:21\/source\/openssl-1\.0\.2\w\.tar\.gz)">.+/\1/g' | \
  sed -n 1p) -O latest_openssl.gzipped && \
tar --extract --file=latest_openssl.gzipped --strip-components=1 --directory=/tmp/openssl && \
cd /tmp/openssl && \
./config --prefix=/usr/local \
  --openssldir=/usr/local/openssl \
  threads \
  zlib && \
make && \
make test && \
make install && \
cd / && \
tar --extract --file=latest_ngnix.gzipped --strip-components=1 --directory=/tmp/nginx && \
cd /tmp/nginx && \
./configure --prefix=/usr/local/nginx \
  --sbin-path=/usr/local/sbin/nginx \
  --conf-path=/opt/nginx-configuration/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/run/lock/subsys/nginx \
  --user=www-data --group=www-data \
  --with-file-aio \
  --with-ipv6 \
  --with-http_ssl_module \
  --with-openssl=/usr/local/openssl \
  --with-http_v2_module \
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
  --with-http_perl_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-pcre \
  --with-google_perftools_module \
  --with-debug && \
make && \
make install

RUN openssl dhparam -out /etc/dh2048.pem 2048
RUN mkdir /add-folder && mkdir -p /www/log
ADD ./run/bootstrap.sh /opt/bootstrap.sh
ADD ./add-folder.sh /add-folder/add-folder.sh
EXPOSE 80 443

CMD ["/bin/bash", "/opt/bootstrap.sh" ]
