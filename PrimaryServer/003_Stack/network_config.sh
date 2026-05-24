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
change_network_config() {
    echo -e "${RECICLE} Adapting network configuration for stack..."

    sed -i "s/VLAN10_CDIR/$VLAN10_CDIR/g" kea/config/kea-dhcp4.conf.prenetworktemplate
    sed -i "s/VLAN10_CONCESION_RANGE/$VLAN10_CONCESION_RANGE/g" kea/config/kea-dhcp4.conf.prenetworktemplate
    sed -i "s/VLAN10_PRIMARY_SERVER_IP/$VLAN10_PRIMARY_SERVER_IP/g" kea/config/kea-dhcp4.conf.prenetworktemplate
    sed -i "s/VLAN20_CDIR/$VLAN20_CDIR/g" kea/config/kea-dhcp4.conf.prenetworktemplate
    sed -i "s/VLAN20_CONCESION_RANGE/$VLAN20_CONCESION_RANGE/g" kea/config/kea-dhcp4.conf.prenetworktemplate
    sed -i "s/VLAN20_PRIMARY_SERVER_IP_WITH_MASK/$VLAN20_PRIMARY_SERVER_IP_WITH_MASK/g" kea/config/kea-dhcp4.conf.prenetworktemplate

    mv kea/config/kea-dhcp4.conf.prenetworktemplate /opt/stack/kea/config/kea-dhcp4.conf
    echo -e "${TICK} Network configuration adapted successfully."
}

# Main execution

source ../.env
change_network_config



