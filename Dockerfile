# 1. Koristimo zvaničnu PHP sliku sa Apache serverom
FROM php:8.2-apache

# 2. Instalacija potrebnih PHP ekstenzija i Composer-a
RUN apt-get update && apt-get install -y \
    libzip-dev unzip libxml2-dev \
    && docker-php-ext-install zip mysqli pdo pdo_mysql \
    && apt-get clean

# 3. Instalacija Composer-a
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Kopiramo ceo projekat u /var/www/html
COPY . /var/www/html/

# 5. Podešavanje prava
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# 6. Omogućavanje Apache mod_rewrite (neophodno za routing)
RUN a2enmod rewrite

# 7. Izlaganje porta 80
EXPOSE 80

# 8. Pokrećemo Apache server
CMD ["apache2-foreground"]
