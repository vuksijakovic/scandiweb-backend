FROM php:8.2-apache

# Instalacija potrebnih PHP ekstenzija
RUN apt-get update && apt-get install -y \
    libzip-dev unzip libxml2-dev \
    && docker-php-ext-install zip mysqli pdo pdo_mysql \
    && apt-get clean

# Dodavanje Composer-a
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Postavljanje root direktorijuma i kopiranje fajlova
WORKDIR /var/www/html
COPY . /var/www/html

# Pokretanje 'composer install'
RUN composer install --no-interaction --prefer-dist

# Podešavanje dozvola
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Kopiranje Apache konfiguracije
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Omogućavanje mod_rewrite za Apache
RUN a2enmod rewrite

# Izlaganje porta
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
