SHELL := /bin/bash

start:
	@echo "Starting containers..."
	@bash ./bin/commands/start.sh

stop:
	@echo "Stopping containers..."
	@bash ./bin/commands/stop.sh
restart:
	@echo "Restarting containers..."
	@$(MAKE) stop
	@$(MAKE) start
down:
	@echo "Stopping and removing containers..."
	@bash ./bin/commands/down.sh

clean:
	@echo "Pruning images, containers, and networks..."
	@$(MAKE) stop
	@bash ./bin/commands/clean.sh
