#!/bin/env bash
if [ "$(docker compose ps -q)" ]; then
    docker compose down -v
fi
docker system prune -a -f --volumes

rm -rf postgresql/data/*
rm -rf kea/config/kea-dhcp4.conf
rm -rf /pihole/etc/*
rm -rf /pihole/logs/*
