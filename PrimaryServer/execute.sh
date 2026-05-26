#!/bin/bash
#VARIABLE DECORATION
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
TICK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
RECICLE="${YELLOW}⟳${NC}"


# FUNCIONS
checkRoot() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${CROSS} Please run as root."
        exit 1
    fi
}

envGenerate(){
    sed -e "s|change_admin|$ADMIN_USER_NAME|g" \
        \
        -e "s|change_netbird_token|$NETBIRD_TOKEN|g" \
        -e "s|change_netbird_url|$NETBIRD_URL|g"
        \
        -e "s|vlan10cdirchange|$VLAN10_CDIR|g" \
        -e "s|vlan10poolchange|$VLAN10_POOL_WE|g" \
        -e "s|vlan10gateway|$VLAN10_GATEWAY|g" \
        -e "s|vlan10serveripchange|$VLAN10_PRIMARY_SERVER_IP_WITH_MASK|g" \
        \
        -e "s|vlan20cdirchange|$VLAN20_CDIR|g" \
        -e "s|vlan20poolchange|$VLAN20_POOL_WE|g" \
        -e "s|vlan20gateway|$VLAN20_GATEWAY|g" \
        -e "s|vlan20dnschange|$VLAN20_DNS_SERVER|g" \
        -e "s|vlan20serveripchange|$VLAN20_PRIMARY_SERVER_IP_WITH_MASK|g" \
        -e "s|vlan20primaryserveripchange|$VLAN20_SERVER_IP_WITHOUT_MASK|g" \
        .env.template > .env
}

getParameters(){
    read -p "Introduce Admin user name: " ADMIN_USER_NAME
    read -p "Introduce Netbird token: " NETBIRD_TOKEN
    read -p "Introduce Netbird URL: " NETBIRD_URL
}

networkValues(){
    read -p "Introduce VLAN10_CDIR. Ej: x.x.x.x/xx: " VLAN10_CDIR
    read -p "Introduce VLAN10_POOL_WE. Ej: x.x.x.x - x.x.x.x: " VLAN10_POOL_WE
    read -p "Introduce VLAN10_GATEWAY. Ej: x.x.x.x: " VLAN10_GATEWAY
    read -p "Introduce VLAN10_SERVER_IP_WITH_MASK. Ej: x.x.x.x/xx: " VLAN10_PRIMARY_SERVER_IP_WITH_MASK


    read -p "Introduce VLAN20_CDIR. Ej: x.x.x.x/xx: " VLAN20_CDIR
    read -p "Introduce VLAN20_POOL_WE. Ej: x.x.x.x - x.x.x.x: " VLAN20_POOL_WE
    read -p "Introduce VLAN20_GATEWAY. Ej: x.x.x.x: " VLAN20_GATEWAY
    read -p "Introduce VLAN20_DNS_SERVER. Ej: x.x.x.x: " VLAN20_DNS_SERVER
    read -p "Introduce VLAN20_SERVER_IP_WITH_MASK. Ej: x.x.x.x/xx: " VLAN20_PRIMARY_SERVER_IP_WITH_MASK
    read -p "Introduce VLAN20_SERVER_IP_WITHOUT_MASK. Ej: x.x.x.x: " VLAN20_SERVER_IP_WITHOUT_MASK
    clear
}



# EXECUTION
checkRoot
getParameters
networkValues

envGenerate

./001_Dependencies/config.sh
./002_NetworkConfig/config.sh

# sleep 15 "For testing with VM, should delete ip route to vlan20 to have internet conexion"

./003_Stack/config.sh
