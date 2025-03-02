# Local Development Env using Traefik and Docker containers

## Structure

- `Makefile` - available commands to up traefik and make ssl
- `/ssl` - config and ssl keys to enamble ssl for named hosts
  - `sites-exmaple.conf` - config to generate ssl key and cert for all NS, should be renabed to `sites.conf`,
    you can set as many NS as you wanna in file config section `alternate_names`
    Example:
    ...
    `DNS.1  = example-wp1.com`
    `DNS.2  = example-wp2.com`
    `DNS.3  = example-wp3.com`
    ...
- `/example` - example of container which can work with `traefik` container
  make attention to the `labels` in `docker-compose yml` there you can set NS for that container,
  with that NS you will be able to open app in web browser
- `/config` - configs for `traefik`
- `/bin` - scripts to meke life easier when manage `ssl`, `/etc/hosts`.
  Please see available commands in `Makefile`

## Getting started commands

- rename `/ssl/sites-example.conf` to `sites.conf`
- add your hostnames in file `sites.conf` to `alternate_names` section like described above
- `make build` - generate ssl keys, create docker network, up traefik container and update hosts file,
  you will be asked for `root` password to update needed files and add certs.
