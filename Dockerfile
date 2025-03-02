FROM traefik:latest
COPY traefik.yaml /etc/traefik/traefik.yaml
COPY dynamic.yaml /etc/traefik/dynamic.yaml
COPY ssl /etc/traefik/ssl
