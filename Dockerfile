FROM php:8.2-apache

# Instalacija potrebnih PHP ekstenzija
RUN apt-get update && apt-get install -y \
    libzip-dev unzip libxml2-dev \
    && docker-php-ext-install zip mysqli pdo pdo_mysql \
    && apt-get clean

# Dodavanje Composer-a
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Postavljanje root direktorijuma na 'public'
WORKDIR /var/www/html
COPY . /var/www/html

# Pokretanje 'composer install' za zavisnosti
RUN composer install --no-interaction --prefer-dist

# Podešavanje dozvola
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Apache konfiguracija za 'public' kao root folder
RUN echo "<VirtualHost *:80>
    DocumentRoot /var/www/html/public
    <Directory /var/www/html/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Omogućavanje mod_rewrite za Apache
RUN a2enmod rewrite

# Izlaganje porta (Docker default: 80 za HTTP)
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
