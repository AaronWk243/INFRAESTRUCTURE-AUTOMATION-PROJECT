# INFRAESTRUCTURE-AUTOMATION-PROJECT

For this project, we created an full stack automated infraestructure for customers who need to deploy DHCP Server (KEA), DNS Server, Frigate Server, LDAP Server and a Simple Wordpress Server integrated with 2 completly separated VLANs for employees and Security devices (Cameras, IoT...).

Infraestructure details:
- VLAN 10:
    - CDIR: 10.0.0.0/xx - x.x.x.x/xx (Concesion starts at x.x.x.35)
    - Gateway: NO
    - DHCP Server: 10.0.0.10
    - DNS Server: NO

    - PRUPOSES: Vlan used only for cameras, IoT devices... because of security reasons. 

- VLAN 20:
    - CDIR: 192.168.0.0/xx - x.x.x.x/xx (Concesion starts at x.x.x.35)
    - Gateway: 192.168.1.1
    - DHCP Server: 192.168.1.10
    - DNS Server: 192.168.1.10

    - PRUPOSES: Vlan used for employees, Internet access, printers, etc...s