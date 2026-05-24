#!/bin/bash
set -e

echo "Checking if database is initialized..."


if kea-admin db-version pgsql -u "$POSTGRES_USER" -p "$POSTGRES_PASSWORD" -n "$POSTGRES_DB" -h 127.0.0.1 > /dev/null 2>&1; then
    echo "=> Database is already initialized. Starting KEA DHCP server..."
else
    echo "=> Database is empty. Initializing structure..."
    kea-admin db-init pgsql -u "$POSTGRES_USER" -p "$POSTGRES_PASSWORD" -n "$POSTGRES_DB" -h 127.0.0.1
fi

echo "=> Starting KEA DHCP server..."

# 'exec "$@"' is fundamental in Docker. Replaces the bash process with the
# main command (kea-dhcp4), allowing Docker to manage its lifecycle properly.
exec "$@"