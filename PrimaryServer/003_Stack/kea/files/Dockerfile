FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    kea-dhcp4-server \
    kea-admin \
    kea-common \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/kea /var/run/kea

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# El CMD ahora solo contiene el comando final, que será pasado al "$@" del entrypoint
CMD ["kea-dhcp4", "-c", "/etc/kea/kea-dhcp4.conf"]
