FROM php:7.3-fpm-alpine3.12

ENV PHP_INI_FILE="/etc/php7/php.ini" \
    PHP_FPM_CONF="/etc/php7/php-fpm.d/www.conf" \
    TZ="Etc/UTC" \
    COMPOSER_ALLOW_SUPERUSER="1" \
    COMPOSER_HOME="/root/.composer" \
    APP_NAME="example"

# Install packages and remove cache
RUN set -ex; \
    apk update ; \
    apk add --no-cache \
    tzdata zip unzip openssl ca-certificates nginx tar msmtp mysql-client supervisor haveged rng-tools \
    php7 php7-fpm php7-cli php7-common php7-opcache \
    php7-ctype php7-curl php7-dom php7-fileinfo php7-gd php7-iconv php7-intl php7-exif php7-json php7-mbstring php7-mysqli php7-openssl php7-pdo php7-pdo_mysql php7-phar php7-posix php7-session php7-memcached php7-shmop php7-simplexml php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter php7-zip php7-zlib ; \
    update-ca-certificates ; \
    rm -rf /var/cache/apk/* ; \
    rm -rf /tmp/* \
    ;

# Configure nginx
COPY assets/devops/localhost.crt /etc/ssl/certs/localhost.crt
COPY assets/devops/localhost.key /etc/ssl/private/localhost.key
COPY assets/devops/nginx.conf /etc/nginx/nginx.conf
COPY assets/devops/default.conf /etc/nginx/conf.d/default.conf
COPY composer.json /var/www/html/composer.json

# Configure supervisord
COPY assets/devops/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Tweak settings
RUN sed -i -e 's~.*expose_php = .*~expose_php = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*date.timezone =.*~date.timezone = "UTC"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*allow_url_fopen = .*~allow_url_fopen = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*display_errors = .*~display_errors = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*display_startup_errors = .*~display_startup_errors = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's/error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_WARNING \& ~E_DEPRECATED \& ~E_STRICT/' ${PHP_INI_FILE} && \
    sed -i -e 's~.*sendmail_path =.*~sendmail_path = "/usr/bin/msmtp -t"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*mail.add_x_header =.*~mail.add_x_header = Off~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*open_basedir =.*~open_basedir = "/var/lib/php:/var/www:/root:/usr/local/bin:/tmp"~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*cgi.fix_pathinfo=.*~cgi.fix_pathinfo=0~' ${PHP_INI_FILE} && \
    sed -i -e 's~.*session.save_handler =.*~session.save_handler = memcached~' ${PHP_INI_FILE} && \
    sed -i -e 's~;session.save_path =.*~session.save_path = memcached-demox:11211~' ${PHP_INI_FILE} && \
    sed -i -e 's~;catch_workers_output = .*~catch_workers_output = yes~' ${PHP_FPM_CONF} && \
    sed -i -e 's~.*listen.backlog =.*~listen.backlog = 1024~' ${PHP_FPM_CONF} && \
    sed -i -e 's~.*clear_env = no~clear_env = no~' ${PHP_FPM_CONF} && \
    sed -i -e "s~.*user =.*~user = nobody~" ${PHP_FPM_CONF} && \    
    sed -i -e "s~.*group =.*~group = nobody~" ${PHP_FPM_CONF} && \
    sed -i -e "s~.*listen\.owner =.*~listen\.owner = nobody~" ${PHP_FPM_CONF} && \    
    sed -i -e "s~.*listen\.group =.*~listen\.group = nobody~" ${PHP_FPM_CONF} && \
    sed -i -e "s~.*listen\.mode =.~listen\.mode = 0660~" ${PHP_FPM_CONF} && \
    sed -i -e 's~.*listen = .*~listen = /run/php-fpm.sock~' ${PHP_FPM_CONF} && \
    sed -i -e 's~.*pm = .*~pm = ondemand~' ${PHP_FPM_CONF} && \
    printf "account default\ndomain localhost\nhost localhost\nport 25\nfrom noreply@localhost\nsyslog LOG_MAIL\n" > /etc/msmtprc

# Setup permissions for nobody user
RUN chown -R nobody.nobody /run && \
  touch /var/log/msmtp.log && \
  chown nobody.nobody /var/log/msmtp.log && \
  chown nobody.nobody /var/log/php7 && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  mkdir -p /var/www/html/demox/application/vendor && mkdir -p /var/log/supervisor && mkdir -p /var/www/vendor && mkdir -p /root/.composer/cache/files && mkdir -p /root/.composer/cache/repo && \
  chown -R nobody.nobody /var/www && \
  chown -R nobody:nobody /var/lib/nginx && \
  chown nobody.nobody /var/log/supervisor && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Make the document root a volume
WORKDIR /var/www/html
#RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer

# Switch to use a non-root user from here on
#USER nobody

# If you make the assumption that you change your codebase more often than your Composer dependencies — then your Dockerfile should run composer install before copying across your codebase. This will mean that your composer install layer will be cached even if your codebase changes. The layer will only be invalidated when you actually change your dependencies.
COPY --chown=nobody . /var/www/html
COPY --chown=nobody demox/cfg.php /var/www/html/demox
#RUN composer dump-autoload --no-scripts --no-dev --optimize

USER root

# Expose the port nginx is reachable on
EXPOSE 8080 8443

# Let supervisord manage everything
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
