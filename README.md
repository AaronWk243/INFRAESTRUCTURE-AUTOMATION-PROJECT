### INFRAESTRUCTURE-AUTOMATION-PROJECT ###

For this project, we designed and implemented a full-stack automated infrastructure for clients requiring deployment of KEA DHCP, DNS, Frigate, LDAP, and a WordPress basic website server. The solution includes two fully segregated VLANs for employees and security devices (CCTV and IoT), along with a WireGuard-based mesh VPN using NetBird to enable secure remote maintenance and management. 
# "/PrimaryServer"

Some automated checkouts and alerts sent to Telegram Bot to detect possible problems with containers, connectivity...
A script used to deploy some basic automated CISCO security and port switch configurations (Anti DHCP-Spoofing...). 
# "/SwitchConfig"


# Needs
- NetBird:
  - Self-Hosted:
    - Domain pointing to your server via Cloudflare P2P...
    - Auth0 (Not required but recommended)
    - NetBird connection KEY (Asked when launching the project)
  - Using NetBird original services:
    - NetBird connection KEY (Asked when launching the project)


# Infraestructure details:
- VLAN 10:
    - Gateway: YES
    - DHCP Server Connection: YES (Long DHCP lease time. Aprox 2 weeks...)
    - DNS Server Connection: NO
    - Web Pannels:
      - Pi-Hole Admin pannel.
      - Frigate ADmin pannel.

    - PRUPOSES: Vlan used only for cameras, IoT devices... because of security reasons. 

- VLAN 20:
    - Gateway: YES
    - DHCP Server Connection: YES
    - DNS Server Connection: YES
    - Web Pannels:
      - Wordpress Website:
  
    - PRUPOSES: Vlan used for employees, Internet access, printers, etc...




### TEST EXECUTION ON VMs ###
- Use 2 network adapters on Client Machine, First one one Bridge Mode (For external connectivity) and a second one on a private LAN Network so you can test DHCP... concesions with other machine on the same LAN.

- Clone the repository.
- Create an admin user for the project, dont use root to avoid possible privilege escalation vulnerabilities.
  

- Uncomment "sleep 15" on "PrimaryServer/execute.sh" so you have time to delete default ip route to 192.168.0.1 with "ip route del ...". Without this, it is possible that you will have problems with network conectivity and it would make "003 -> configure.sh" script to fail pulling docker images.
      
- On "003_Stack/docker-compose.yaml", you should point Pi-Hole IP Addresses to your IP of the bridged network adapter, so you can enter with your real SO pointing on the browser "{https-http}://BridgedIP:{1500-15001}/admin" (On HTTP/s you should accept SSL risk in case your browser asks). To enter Pi-Hole control pannel you can use VMs on the LAN Network, but you should have GUI and a Network Adapter configured for the VLAN 10/20 (Recommended to use VLAN 10 on docker-compose.yaml for PI-Hole pannel and other critical services for security reasons).
    - In case you want to make a LAN Adapter configured to the VLANs, you can run this commands:
        - Linux:
            - ip link add link ifaceX name ifaceX.VlanX type vlan id X
            - ip link set dev ifaceX up (Just in case it is not up)
            - ip link set dev ifaceX.VlanX up
            - dhclient ifaceX.VlanX (To receive IP config from the DHCP Server)

- Scroll on your CLI to "PrimaryServer/" and execute "./execute.sh". In case you are unable to execute it, make sure you run "chmod +x ./execute.sh" and try one more time.


### PRODUCTION EXECUTION ###

  
