SHELL := /bin/bash

start:
	@echo "Starting Traefik..."
	@bash ./bin/commands/start.sh

build:
	@echo "Updating SSL certificates..."
	@bash ./bin/commands/update_cert.sh
	@bash ./bin/commands/trust_cert.sh
	@bash ./bin/commands/update_hosts.sh
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
