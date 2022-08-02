#!/usr/bin/env bash
sudo mkdir -p /var/log/{green-backend/nginx,blue-backend/nginx,nginx}
sudo docker-compose up -d --build
