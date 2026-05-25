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

StackRoute=/opt/stack001


#REQUIRED FUNCTIONS

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${CROSS} Please run as root."
        exit 1
    fi
}

generateStackStructure(){
    mkdir -p /opt/stack001 /opt/stack001/kea/config /opt/stack001/kea/files /opt/stack001/pihole/etc /opt/stack001/pihole/logs /opt/stack001/postgresql/data
    
    cp docker-compose.yaml /opt/stack001/docker-compose.yaml
    cp .env.template /opt/stack001/.env.template
    cp kea/files/Dockerfile /opt/stack001/kea/files/Dockerfile
    cp kea/files/entrypoint.sh /opt/stack001/kea/files/entrypoint.sh

}

password_generate(){
    openssl rand -hex 32
}
rand_generate(){
    openssl rand -hex 2
}

#PROGRAM FUNCTIONS

envGenerate(){
    sed -e "s|postgreschangeuser|$randGenerated1|g" \
        -e "s|postgreschangepassword|$passwordGenerated1|g" \
        -e "s|postgreschangedb|$randGenerated2|g" \
        -e "s|piholechangepassword|$passwordGenerated2|g" \
        -e "s|timezonechange|$timezoneGenerated|g" \
        -e "s|vlan10cdirchange|$VLAN10_CDIR|g" \
        -e "s|vlan10poolchange|$VLAN10_POOL_WE|g" \
        -e "s|vlan10gateway|$VLAN10_GATEWAY|g" \
        -e "s|vlan20cdirchange|$VLAN20_CDIR|g" \
        -e "s|vlan20poolchange|$VLAN20_POOL_WE|g" \
        -e "s|vlan20gateway|$VLAN20_GATEWAY|g" \
        -e "s|vlan20dnschange|$VLAN20_DNS_SERVER|g" \
        .env.template > $StackRoute/.env
}
keaGenerate(){
    sed -e "s|postgreschangedb|$randGenerated2|g" \
         -e "s|postgreschangeuser|$randGenerated1|g" \
        -e "s|postgreschangepassword|$passwordGenerated1|g" \
        -e "s|VLAN10_CDIR|$VLAN10_CDIR|g" \
        -e "s|VLAN10_POOL_WE|$VLAN10_POOL_WE|g" \
        -e "s|VLAN10_GATEWAY|$VLAN10_GATEWAY|g" \
        -e "s|VLAN20_CDIR|$VLAN20_CDIR|g" \
        -e "s|VLAN20_POOL_WE|$VLAN20_POOL_WE|g" \
        -e "s|VLAN20_GATEWAY|$VLAN20_GATEWAY|g" \
        -e "s|VLAN20_DNS_SERVER|$VLAN20_DNS_SERVER|g" \
    ./kea/config/kea-dhcp4.conf.template > $StackRoute/kea/config/kea-dhcp4.conf

}

networkValues(){
    read -p "Introduce VLAN10_CDIR. Ej: 10.0.0.0/23: " VLAN10_CDIR
    read -p "Introduce VLAN10_POOL_WE. Ej: 10.0.0.35 - 10.0.1.254: " VLAN10_POOL_WE
    read -p "Introduce VLAN10_GATEWAY. Ej: 10.0.0.1: " VLAN10_GATEWAY
    read -p "Introduce VLAN20_CDIR. Ej: 192.168.0.0/24: " VLAN20_CDIR
    read -p "Introduce VLAN20_POOL_WE. Ej: 192.168.0.50 - 192.168.0.200: " VLAN20_POOL_WE
    read -p "Introduce VLAN20_GATEWAY. Ej: 192.168.0.1: " VLAN20_GATEWAY
    read -p "Introduce VLAN20_DNS_SERVER. Ej: 10.0.0.10: " VLAN20_DNS_SERVER
}




### MAIN PROGRAM ###
# Pre-checks
check_root
source ../.env
generateStackStructure


# Generating variables and configuration files
passwordGenerated1=$(password_generate)
passwordGenerated2=$(password_generate)
randGenerated1=$(rand_generate)
randGenerated2=$(rand_generate)
timezoneGenerated=$(timedatectl show --property=Timezone --value)
networkValues


envGenerate
keaGenerate


# Stack execution
docker compose -f "$StackRoute/docker-compose.yaml" up -d
