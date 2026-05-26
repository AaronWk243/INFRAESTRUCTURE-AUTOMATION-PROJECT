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


CodeRoute='./003_Stack'
StackRoute=/opt/stack001


#REQUIRED FUNCTIONS

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${CROSS} Please run as root."
        exit 1
    fi
}

generateStackStructure(){
    mkdir -p $StackRoute $StackRoute/kea/config $StackRoute/kea/files $StackRoute/pihole/etc \
    $StackRoute/pihole/logs $StackRoute/postgresql/data
    
    cp $CodeRoute/docker-compose.yaml $StackRoute/docker-compose.yaml
    cp $CodeRoute/kea/files/Dockerfile $StackRoute/kea/files/Dockerfile
    cp $CodeRoute/kea/files/entrypoint.sh $StackRoute/kea/files/entrypoint.sh

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
        $CodeRoute/.env.template > $StackRoute/.env
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
    $CodeRoute/kea/config/kea-dhcp4.conf.template > $StackRoute/kea/config/kea-dhcp4.conf

}


securityConfig(){
    chown $ADMIN_USER_NAME:$ADMIN_USER_NAME $StackRoute -R
    chmod 700 $StackRoute -R

}


### MAIN PROGRAM ###
# Pre-checks
check_root
source .env
generateStackStructure


# Generating variables
passwordGenerated1=$(password_generate)
passwordGenerated2=$(password_generate)
randGenerated1=$(rand_generate)
randGenerated2=$(rand_generate)
timezoneGenerated=$(timedatectl show --property=Timezone --value)

# GENERATE .env and kea-dhcp4.conf files with generated variables and values from .env file
envGenerate
source $StackRoute/.env
keaGenerate

securityConfig

# Stack execution
docker compose -f "$StackRoute/docker-compose.yaml" up -d 
