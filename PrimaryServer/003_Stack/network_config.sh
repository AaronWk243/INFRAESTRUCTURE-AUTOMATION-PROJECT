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

KEA_TEMPLATE='kea/config/kea-dhcp4.conf.prenetworktemplate'


# Stack configuration functions
change_network_config() {
    echo -e "${RECICLE} Adapting network configuration for stack..."

    sed -i \
    -e "s|VLAN10_CDIR|$VLAN10_CDIR|g" \
    -e "s|VLAN10_CONCESION_RANGE|$VLAN10_CONCESION_RANGE|g" \
    -e "s|VLAN10_PRIMARY_SERVER_IP|$VLAN10_PRIMARY_SERVER_IP|g" \
    -e "s|VLAN10_GATEWAY|$VLAN10_GATEWAY|g" \
    -e "s|VLAN20_CDIR|$VLAN20_CDIR|g" \
    -e "s|VLAN20_CONCESION_RANGE|$VLAN20_CONCESION_RANGE|g" \
    -e "s|VLAN20_PRIMARY_SERVER_IP|$VLAN20_PRIMARY_SERVER_IP|g" \
    -e "s|VLAN20_GATEWAY|$VLAN20_GATEWAY|g" \
    "$KEA_TEMPLATE"
}

# Main execution

source ../.env
change_network_config



