SHELL := /bin/bash

start:
	@echo "Starting Traefik..."
	@bash ./bin/commands/start.sh
stop:
	@echo "Stopping Traefik..."
	@bash ./bin/commands/stop.sh
down:
	@echo "Down Traefik containers..."
	@bash ./bin/commands/down.sh
build:
	@echo "Updating SSL certificates..."
	@$(MAKE) update_ssl
	@$(MAKE) update_hosts
	@$(MAKE) start
restart:
	@echo "Restarting containers..."
	@$(MAKE) stop
	@$(MAKE) start
update_hosts:
	@echo "Updating hosts file..."
	@bash ./bin/commands/update_hosts.sh

update_ssl:
	@echo "Updating SSL certificates..."
	@bash ./bin/commands/update_cert.sh
	@bash ./bin/commands/trust_cert.sh
	@$(MAKE) update_hosts

trust_ssl:
	@echo "Trusting SSL certificate..."
	@bash ./bin/commands/trust_cert.sh
