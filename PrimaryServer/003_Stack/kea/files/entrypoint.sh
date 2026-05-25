#!/bin/bash
set -e

echo "Comprobando el estado de la base de datos de KEA..."

# Usamos db-version para ver si las tablas ya existen. 
# Si el comando tiene éxito, la BDD ya está inicializada.
if kea-admin db-version pgsql -u "$POSTGRES_USER" -p "$POSTGRES_PASSWORD" -n "$POSTGRES_DB" -h 127.0.0.1 > /dev/null 2>&1; then
    echo "=> La base de datos ya está inicializada. Omitiendo db-init..."
else
    echo "=> La base de datos está vacía. Inicializando estructura..."
    kea-admin db-init pgsql -u "$POSTGRES_USER" -p "$POSTGRES_PASSWORD" -n "$POSTGRES_DB" -h 127.0.0.1
fi

echo "=> Iniciando servidor KEA DHCP..."

# 'exec "$@"' es fundamental en Docker. Reemplaza el proceso de bash por el 
# comando principal (kea-dhcp4), permitiendo que Docker gestione bien su ciclo de vida.
exec "$@"
