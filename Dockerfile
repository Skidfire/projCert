FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y nginx php7.2-fpm php7.2-bcmath php7.2-curl php7.2-gd php7.2-mbstring php7.2-mysql php7.2-x
#php7 php7-fpm php7-intl php7-mysql php7-xdebug
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;\?daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf

# Nginx config
RUN rm /etc/nginx/sites-enabled/default
#ADD ./site.conf /etc/nginx/sites-available/

RUN printf 'server {\n\
    listen         80;\n\
    listen         [::]:80;\n\
    root           /website;\n\
    index          index.php index.html;\n\
    server_name    php-docker.local;\n\
    error_log      /var/log/nginx/error.log;\n\
    access_log     /var/log/nginx/access.log;\n\
\n\
  location ~* \.php$ {\n\
    fastcgi_pass    unix:/run/php/php7.2-fpm.sock;\n\
    include         fastcgi_params;\n\
    fastcgi_param   SCRIPT_FILENAME    $document_root$fastcgi_script_name;\n\
    fastcgi_param   SCRIPT_NAME        $fastcgi_script_name;\n\
  }\n\
}' > /etc/nginx/sites-available/site.conf

RUN ln -s /etc/nginx/sites-available/site.conf /etc/nginx/sites-enabled/site.conf

# PHP config
RUN sed -i -e "s/;\?date.timezone\s*=\s*.*/date.timezone = Europe\/Berlin/g" /etc/php/7.2/fpm/php.ini

COPY ./website /website

# Define default command.
CMD service php7.2-fpm start && nginx

# Expose ports.
EXPOSE 80
