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
WARNING="${YELLOW}⚠${NC}"

ProgramRoute="./002_NetworkConfig"

# Network configuration functions
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${CROSS} Please run as root."
        exit 1
    fi
}

disable_ipv6() {
    if [ -f "/etc/sysctl.d/99-sysctl.conf" ]; then
        read -p 'IPv6 configuration already exists. Do you want to overwrite it? (y/n): ' OVERWRITE_IPV6
        if [[ "$OVERWRITE_IPV6" == "n" || "$OVERWRITE_IPV6" == "N" ]]; then
            echo -e "${TICK} Keeping existing IPv6 configuration."
            chown root:root /etc/sysctl.d/99-sysctl.conf
            chmod 640 /etc/sysctl.d/99-sysctl.conf
            return 0

        elif [[ "$OVERWRITE_IPV6" == "y" || "$OVERWRITE_IPV6" == "Y" ]]; then
            echo -e "${RECICLE} Overwriting IPv6 configuration..."
            rm -f /etc/sysctl.d/99-sysctl.conf
        else
            echo -e "${CROSS} Invalid input. Please enter 'y' or 'n'."
            exit 1
        fi
    fi

    echo -e "${RECICLE} Creating IPv6 configuration..."

    touch /etc/sysctl.d/99-sysctl.conf
    chown root:root /etc/sysctl.d/99-sysctl.conf
    chmod 640 /etc/sysctl.d/99-sysctl.conf

    echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/99-sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/99-sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.d/99-sysctl.conf

    if sysctl -p /etc/sysctl.d/99-sysctl.conf > /dev/null 2>&1; then
        echo -e "${TICK} IPv6 disabled successfully."
    else
        echo -e "${CROSS} Failed to apply IPv6 configuration."
        exit 1
    fi
}

disable_network_manager() {
    if systemctl is-active --quiet NetworkManager; then
        echo -e "${RECICLE} Disabling NetworkManager..."
        systemctl stop NetworkManager
        systemctl disable NetworkManager
        echo -e "${TICK} NetworkManager disabled successfully."
    else
        echo -e "${TICK} NetworkManager is already disabled."
    fi
}

enable_systemd() {
    systemctl enable systemd-networkd
    systemctl start systemd-networkd
}

check_netplan_exists() {
    if [ -f "/etc/netplan/01_netcfg.yaml" ]; then
        echo -e "${TICK} Netplan configuration file already exists."
        read -p 'Do you want to delete it and make a new one? (y/n): ' DELETE_NETPLAN
        if [[ "$DELETE_NETPLAN" == "y" || "$DELETE_NETPLAN" == "Y" ]]; then
            rm -f /etc/netplan/01_netcfg.yaml
            echo -e "${TICK} Netplan configuration deleted succesfully."

        elif [[ "$DELETE_NETPLAN" == "n" || "$DELETE_NETPLAN" == "N" ]]; then
            echo -e "${TICK} Keeping existing netplan configuration."
            exit 0
        else  
            echo -e "${CROSS} Invalid input. Please enter Y/N n."
        fi
    fi
}

configuration(){
    interfaces=()
    for i in /sys/class/net/*; do
        name=$(basename "$i")
        [[ "$name" == lo || "$name" == docker* ]] && continue
        interfaces+=("$name")
    done

    echo -e "Select one interface to install VLAN configuration:"
    select ifazXselected in "${interfaces[@]}"; do
        [[ -n "$ifazXselected" ]] && break
        echo -e "${CROSS} Invalid selection. Please try again."
    done

    sed -e "s|ifazXchange|$ifazXselected|g" \
        -e "s|VLAN10_SERVER_IP_WM|$VLAN10_SERVER_IP_WM|g" \
        -e "s|VLAN20_SERVER_IP_WM|$VLAN20_SERVER_IP_WM|g" \
        -e "s|VLAN20_GATEWAY|$VLAN20_GATEWAY|g" \
        -e "s|VLAN20_SERVER_IP_NM|$VLAN20_SERVER_IP_NM|g" \
        "$ProgramRoute/01_netcfg.yaml.template" > "$ProgramRoute/01_netcfg.yaml.workingtemplate"

    if cp "$ProgramRoute/01_netcfg.yaml.workingtemplate" "/etc/netplan/01_netcfg.yaml"; then
        rm "$ProgramRoute/01_netcfg.yaml.workingtemplate"

        echo -e "${TICK} 01_netcfg.yaml created from template."
    else
        echo -e "${CROSS} Creating netplan configuration file failed"
        exit 1
    fi

    chown root:root "/etc/netplan/01_netcfg.yaml"
    chmod 600 "/etc/netplan/01_netcfg.yaml"
    
    sleep 1

    if /usr/sbin/netplan apply; then
        echo -e "${TICK} Network configuration applied successfully."
    else
        echo -e "${CROSS} Failed to apply network configuration."
        exit 1
    fi
}


# PROGRAM EXECUTION
source .env
check_root
disable_ipv6
disable_network_manager
enable_systemd
check_netplan_exists
configuration
#ip route del default via 192.168.0.1 dev vlan20 proto static #Used only for testing on VMs
