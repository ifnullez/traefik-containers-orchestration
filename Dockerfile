FROM traefik:latest
COPY traefik.yaml /etc/traefik/traefik.yaml
COPY traefik_dynamic.yaml /etc/traefik/traefik_dynamic.yaml
COPY ssl /etc/traefik/ssl
