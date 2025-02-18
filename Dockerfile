FROM php:8.1-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/rpgmanager/

# Set working directory
WORKDIR /var/www/rpgmanager/

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libzip-dev \
    libjpeg-dev \
    libonig-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql mbstring zip exif pcntl

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 rpgmanager
RUN useradd -u 1000 -ms /bin/bash -g rpgmanager rpgmanager

# Copy existing application directory contents
COPY . /var/www/rpgmanager/

# Copy existing application directory permissions
RUN chown -R rpgmanager:rpgmanager /var/www/rpgmanager

# Change current user to www
USER rpgmanager

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]