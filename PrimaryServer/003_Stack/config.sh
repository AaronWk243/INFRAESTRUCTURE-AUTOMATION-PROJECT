#!/bin/env bash
set -e

#VARIABLE DECORATION
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
TICK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
RECICLE="${YELLOW}⟳${NC}"
WARNING="${YELLOW}⚠${NC}"

# Stack configuration functions
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${CROSS} Please run as root."
        exit 1
    fi
}

create_folders() {
    echo -e "${RECICLE} Creating necessary folders..."
    mkdir -p /opt/stack/kea/config
    mkdir -p /opt/stack/kea/files
    cp ./kea/files/* /opt/stack/kea/files/

    mkdir -p /opt/stack/pihole/etc
    mkdir -p /opt/stack/pihole/logs

    mkdir -p /opt/stack/postgres/data

    cp docker-compose.yaml /opt/stack/docker-compose.yaml

    chown -R root:root /opt/stack
    chmod -R 755 /opt/stack
}


# Generate random passwords and environment variables
password_generate(){
    openssl rand -hex 32
}
rand_generate(){
    openssl rand -hex 2
}

env_generate(){

    sed -e "s/postgreschangeuser/user$rand_generated1/g" \
        -e "s/postgreschangepassword/$password_generated_kea_postgresql/g" \
        -e "s/postgreschangedb/db_$rand_generated2/g" \
        -e "s/piholechangepassword/$password_generated_pihole/g" \
        -e "s|timezone_change|$timezone_generated|g" \
         .env.template > /opt/stack/.env
}

kea_config_generate(){
    if [ -f ../.]
    sed -e "s/\"name\": \"postgreschangedb\"/\"name\": \"db_$rand_generated2\"/g" \
        -e "s/\"user\": \"postgreschangeuser\"/\"user\": \"user$rand_generated1\"/g" \
        -e "s/\"password\": \"postgreschangepassword\"/\"password\": \"$password_generated_kea_postgresql\"/g" \
        kea/config/kea-dhcp4.conf.template > kea/config/kea-dhcp4.conf.prenetworktemplate

        chmod +x ./network_config.sh
        ./network_config.sh
        mv kea/config/kea-dhcp4.conf.prenetworktemplate /opt/stack/kea/config/kea-dhcp4.conf
}




# Main execution
check_root
create_folders
password_generated_kea_postgresql=$(password_generate)
password_generated_pihole=$(password_generate)
rand_generated1=$(rand_generate)
rand_generated2=$(rand_generate)
timezone_generated=$(timedatectl show --property=Timezone --value)

env_generate
kea_config_generate

docker compose up -d dhcp-postgres
docker compose up -d dhcp-kea
docker compose up -d dns-pihole