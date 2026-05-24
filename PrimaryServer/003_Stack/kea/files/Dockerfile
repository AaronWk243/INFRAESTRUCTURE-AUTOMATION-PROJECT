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

# Used by the entrypoint to initialize the database if needed, then start the server.
CMD ["kea-dhcp4", "-c", "/etc/kea/kea-dhcp4.conf"]