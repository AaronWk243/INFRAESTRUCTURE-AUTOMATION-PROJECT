# INFRAESTRUCTURE-AUTOMATION-PROJECT

For this project, we created an full stack automated infraestructure for customers who need to deploy DHCP Server (KEA), DNS Server, Frigate Server, LDAP Server and a Simple Wordpress Server integrated with 2 completly separated VLANs for employees and Security devices (Cameras, IoT...).

Infraestructure details:
- VLAN 10:
    - CDIR: 
    - Gateway: NO
    - DHCP Server: 10.0.0.10
    - DNS Server: NO

    - PRUPOSES: Vlan used only for cameras, IoT devices... because of security reasons. 

- VLAN 20:
    - CDIR: 
    - Gateway: 
    - DHCP Server: 
    - DNS Server: 

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

  
