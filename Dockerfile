FROM nimmis/alpine-micro

MAINTAINER nimmis <kjell.havneskold@gmail.com>

COPY root/. /

RUN apk update && apk upgrade && \

    # Make info file about this build
    printf "Build of nimmis/alpine-apache, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` >> /etc/BUILD && \

    apk add apache2 libxml2-dev apache2-utils && \
    mkdir /web/ && chown -R apache.www-data /web && \
   
    sed -i 's#^DocumentRoot ".*#DocumentRoot "/web/html"#g' /etc/apache2/httpd.conf && \
    sed -i 's#AllowOverride none#AllowOverride All#' /etc/apache2/httpd.conf && \
    sed -i 's#^ServerRoot .*#ServerRoot /web#g'  /etc/apache2/httpd.conf && \
    sed -i 's/^#ServerName.*/ServerName webproxy/' /etc/apache2/httpd.conf && \
    sed -i 's#^IncludeOptional /etc/apache2/conf#IncludeOptional /web/config/conf#g' /etc/apache2/httpd.conf && \
    sed -i 's#PidFile "/run/.*#Pidfile "/web/run/httpd.pid"#g'  /etc/apache2/conf.d/mpm.conf && \
    sed -i 's#Directory "/var/www/localhost/htdocs.*#Directory "/web/html" >#g' /etc/apache2/httpd.conf && \
    sed -i 's#Directory "/var/www/localhost/cgi-bin.*#Directory "/web/cgi-bin" >#g' /etc/apache2/httpd.conf && \

    sed -i 's#/var/log/apache2/#/web/logs/#g' /etc/logrotate.d/apache2 && \
    sed -i 's/Options Indexes/Options /g' /etc/apache2/httpd.conf && \
    echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "@edge https://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && apk upgrade && \

    # Make info file about this build
    printf "Build of nimmis/alpine-apache-php7, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` >> /etc/BUILD && \
    apk add libressl@edge && \
    apk add curl openssl && \
    apk add php7@community php7-apache2@community php7-openssl@community php7-mbstring@community && \
    apk add php7-apcu@testing php7-intl@community php7-mcrypt@community php7-json@community php7-gd@community php7-curl@community && \
    apk add php7-fpm@community php7-mysqlnd@community php7-pgsql@community php7-sqlite3@community php7-phar@community && \
    # waiting for module to be release on alpine
    # apk add php7-imagick@testing
    ln -s /usr/bin/php7 /usr/bin/php && \
    cd /tmp && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
    rm -rf /var/cache/apk/*


VOLUME /web

EXPOSE 80 443


