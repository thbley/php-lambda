# Build PHP for Lambda
FROM amazonlinux:2018.03.0.20190514 as builder

RUN sed -i 's;^releasever.*;releasever=2018.03;;' /etc/yum.conf && \
    yum clean all && \
    yum install -y autoconf bison gcc gcc-c++ libcurl-devel libxml2-devel openssl-devel

# Compile PHP binary
RUN curl -sL https://github.com/php/php-src/archive/php-7.3.6.tar.gz | tar -xz && \
    cd php-src-php-7.3.6 && \
    ./buildconf --force && \
    ./configure --prefix=/opt/php/ --with-openssl --with-curl --with-zlib --with-mysqli --with-pdo-mysql \
    --enable-mbstring --without-sqlite3 --without-pdo-sqlite --without-pear && \
    make install

# Create runtime container for use with lambdaci
FROM lambci/lambda:provided as runtime

COPY --from=builder /opt/php/bin/php /opt/bin/php

