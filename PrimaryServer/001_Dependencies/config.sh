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

# Package management and dependencies installation functions

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${CROSS} Please run as root."
        exit 1
    fi
}

check_external_conectivity() {
    if ping -c 1 google.com &> /dev/null; then
        echo -e "${TICK} External connectivity is working."
    else
        echo -e "${CROSS} No external connectivity. Please check your network settings."
        exit 1
    fi
}

update_system() {
    if apt update && apt upgrade -y; then
        echo -e "${TICK} System updated successfully."
    else
        echo -e "${CROSS} Failed to update system packages."
        exit 1
    fi
}

prerequisites_install() {
    if apt install ca-certificates curl gnupg lsb-release netplan.io net-tools iputils-ping -y > /dev/null 2>&1; then
        echo -e "${TICK} Prerequisites installed successfully."
    else
        echo -e "${CROSS} Failed to install prerequisites."
        exit 1
    fi
}

docker_install(){
    if docker --version &> /dev/null; then
        echo -e "${TICK} Docker is already installed."
    else
        echo -e "${RECICLE} Installing Docker..."
        
        # Prerequisites
        curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
        chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt update > /dev/null 2>&1

        if apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y; then
            echo -e "${TICK} Docker installed successfully."
        else
            echo -e "${CROSS} Failed to install Docker."
            exit 1
        fi
    fi
    systemctl enable docker
    systemctl start docker
}

netbird_install(){
    if netbird version &> /dev/null; then
        echo -e "${TICK} Netbird is already installed."
    else
        echo -e "${RECICLE} Installing Netbird..."
        curl -fsSL https://pkgs.netbird.io/install.sh | sh > /dev/null 2>&1
        if netbird version &> /dev/null; then
            echo -e "${TICK} Netbird installed successfully."
        else
            echo -e "${CROSS} Failed to install Netbird."
            exit 1
        fi
    fi
    systemctl enable netbird
    systemctl start netbird
}


# System configuration functions
grub_optimization() {
    if grep -q "^GRUB_TIMEOUT=0" /etc/default/grub; then
        echo -e "${TICK} GRUB is already optimized. Skipping..."
        return 0
    fi

    echo -e "${RECICLE} Optimizing GRUB..."

    if grep -q "^GRUB_TIMEOUT=" /etc/default/grub; then
        sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
    else
        echo "GRUB_TIMEOUT=0" >> /etc/default/grub
    fi

    echo -e "${TICK} GRUB optimized successfully."

    if update-grub > /dev/null 2>&1; then
        echo -e "${TICK} GRUB updated successfully."
    else
        echo -e "${CROSS} Failed to update GRUB."
        exit 1
    fi
}


# PROGRAM EXECUTION
set -eo pipefail
check_root
check_external_conectivity
update_system
prerequisites_install
docker_install
netbird_install
grub_optimization