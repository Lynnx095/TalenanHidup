#!/bin/bash

# Create docker-compose.yml
cat <<EOT >> docker-compose.yml
version: '3'

services:
  db:
    image: mariadb
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    restart: always
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: your_root_password
      MYSQL_PASSWORD: your_nextcloud_password
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud

  app:
    image: linuxserver/nextcloud:27.1.4-ls289
    ports:
      - 7080:80
      - 7443:443
    links:
      - db
    volumes:
      - nextcloud:/var/www/html
      - ./php.ini:/usr/local/etc/php/conf.d/upload.ini
    environment:
      MYSQL_PASSWORD: your_nextcloud_password
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_HOST: db
    restart: always

volumes:
  db_data:
  nextcloud:
EOT

# Create php.ini
cat <<EOT >> php.ini
upload_max_filesize = 10240M
post_max_size = 10240M
memory_limit = 512M
max_execution_time = 1000
EOT

# Deploy containers
docker-compose up -d
