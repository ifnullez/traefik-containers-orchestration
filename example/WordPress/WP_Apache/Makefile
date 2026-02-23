SHELL := /bin/bash

# ─── Resolve tooling ─────────────────────────────────────────────────────────
COMPOSE       := $(shell ./bin/resolve_compose.sh)
CONTAINER_CMD := $(shell ./bin/container_cmd.sh)

ifeq ($(COMPOSE),error)
  $(error Compose command not found. Install docker-compose or podman-compose)
endif

ifeq ($(CONTAINER_CMD),error)
  $(error Container runtime not found. Install Docker or Podman)
endif

# ─── Service names ────────────────────────────────────────────────────────────
APP_CONTAINER   := app
DB_CONTAINER    := db
SERVER_CONTAINER := app

# ─── Colors ──────────────────────────────────────────────────────────────────
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
CYAN   := \033[0;36m
NC     := \033[0m

# ─── Pass-through args for logs, shell, exec, wp ─────────────────────────────
# Usage: make logs api    →  CMD_ARGS = api
# Usage: make exec api ls →  CMD_ARGS = api ls
ifneq ($(filter logs shell exec wp,$(firstword $(MAKECMDGOALS))),)
  CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CMD_ARGS):;@:)
endif

.PHONY: help \
        start up stop down restart \
        build rebuild clean \
        status logs shell exec \
        wp server-reload server-test opcache-clear

# ─── Help ─────────────────────────────────────────────────────────────────────

help: ## Show this help
	@echo ""
	@echo -e "  $(CYAN)Project Container Management$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "  Runtime: $(CYAN)$(CONTAINER_CMD)$(NC)   Compose: $(CYAN)$(COMPOSE)$(NC)"
	@echo ""

# ─── Lifecycle ───────────────────────────────────────────────────────────────

start: ## Start containers in detached mode (alias: up)
	@./bin/commands/start.sh

up: start ## Alias for start

stop: ## Stop containers (keeps them, use 'start' to resume)
	@./bin/commands/stop.sh

down: ## Stop and remove containers (add ARGS for extra flags)
	@./bin/commands/down.sh $(ARGS)

restart: ## Restart all containers
	@echo -e "$(YELLOW)Restarting containers...$(NC)"
	@$(COMPOSE) restart
	@echo -e "$(GREEN)✓ Restarted$(NC)"

# ─── Build ───────────────────────────────────────────────────────────────────

build: ## Build images
	@./bin/commands/build.sh

rebuild: ## Rebuild images without cache
	@./bin/commands/build.sh --no-cache

# ─── Clean ───────────────────────────────────────────────────────────────────

clean: ## Remove stopped containers, dangling images, unused volumes & networks
	@echo -e "$(RED)Cleaning up unused resources...$(NC)"
	@./bin/commands/clean.sh
	@echo -e "$(RED)✓ Done$(NC)"

clean-all: ## Full teardown: compose down -v --rmi local, then full prune
	@echo -e "$(RED)Full teardown...$(NC)"
	@./bin/commands/down.sh --volumes --rmi local --remove-orphans
	@./bin/commands/clean.sh --all
	@echo -e "$(RED)✓ Done$(NC)"

# ─── Observability ───────────────────────────────────────────────────────────

status: ## Show container status
	@$(COMPOSE) ps

logs: ## Tail logs (make logs [SERVICE])
	@$(COMPOSE) logs -f $(CMD_ARGS)

# ─── Shell access ─────────────────────────────────────────────────────────────

shell: ## Open shell in a container (make shell [SERVICE=app])
	@container="$(firstword $(CMD_ARGS))"; \
	container=$${container:-$(APP_CONTAINER)}; \
	$(CONTAINER_CMD) exec -it $$($(COMPOSE) ps -q $$container) /bin/sh

exec: ## Run a command in a container (make exec <SERVICE> <CMD...>)
	@container="$(firstword $(CMD_ARGS))"; \
	if [ -z "$$container" ]; then \
		echo -e "$(RED)Usage: make exec <service> <command>$(NC)"; \
		exit 1; \
	fi; \
	cmd="$(wordlist 2,$(words $(CMD_ARGS)),$(CMD_ARGS))"; \
	if [ -z "$$cmd" ]; then \
		echo -e "$(RED)Usage: make exec <service> <command>$(NC)"; \
		exit 1; \
	fi; \
	$(CONTAINER_CMD) exec -it $$($(COMPOSE) ps -q $$container) $$cmd

# ─── WordPress ───────────────────────────────────────────────────────────────

wp: ## Run WP-CLI (make wp <command>)
	@if [ -z "$(CMD_ARGS)" ]; then \
		echo -e "$(RED)Usage: make wp <command>$(NC)"; \
		echo -e "Example: $(YELLOW)make wp plugin list$(NC)"; \
		exit 1; \
	fi
	@$(CONTAINER_CMD) exec -it $$($(COMPOSE) ps -q $(APP_CONTAINER)) wp $(CMD_ARGS) --allow-root

# ─── SERVER ───────────────────────────────────────────────────────────────────

server-reload: ## Reload Apache config without downtime
	@$(CONTAINER_CMD) exec $$($(COMPOSE) ps -q $(SERVER_CONTAINER)) apache2ctl graceful
	@echo -e "$(GREEN)✓ Apache reloaded$(NC)"

server-test: ## Test Apache config validity
	@$(CONTAINER_CMD) exec $$($(COMPOSE) ps -q $(SERVER_CONTAINER)) apache2ctl configtest

# ─── PHP ─────────────────────────────────────────────────────────────────────

opcache-clear: ## Clear PHP opcache
	@$(CONTAINER_CMD) exec $$($(COMPOSE) ps -q $(APP_CONTAINER)) \
		php -r "opcache_reset();" 2>/dev/null \
		|| echo -e "$(YELLOW)Opcache not enabled or already clear$(NC)"
	@echo -e "$(GREEN)✓ Done$(NC)"
