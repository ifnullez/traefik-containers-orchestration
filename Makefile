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

# ─── Container names ─────────────────────────────────────────────────────────
TRAEFIK_CONTAINER := traefik

# ─── Colors ──────────────────────────────────────────────────────────────────
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
CYAN   := \033[0;36m
BOLD   := \033[1m
NC     := \033[0m

# ─── Pass-through args for logs, exec ────────────────────────────────────────
ifneq ($(filter logs exec,$(firstword $(MAKECMDGOALS))),)
  CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CMD_ARGS):;@:)
endif

.PHONY: help \
        start up stop down restart \
        build rebuild clean clean-all \
        status logs exec \
        cert trust-cert update-hosts update-hosts-dry \
        setup

# ─── Help ─────────────────────────────────────────────────────────────────────

help: ## Show this help
	@echo ""
	@echo -e "  $(BOLD)$(CYAN)Traefik Container Management$(NC)"
	@echo ""
	@echo -e "  Runtime : $(CYAN)$(CONTAINER_CMD)$(NC)"
	@echo -e "  Compose : $(CYAN)$(COMPOSE)$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "; section=""} \
		/^# ={5,}/ { \
			gsub(/^# =+[[:space:]]?/, ""); gsub(/[[:space:]]?=+$$/, ""); \
			printf "\n  $(BOLD)%s$(NC)\n", $$0; next \
		} \
		/^[a-zA-Z_-]+:.*?## / { \
			printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 \
		}' $(MAKEFILE_LIST)
	@echo ""

# ==================== SETUP ====================

setup: ## Full first-run setup: generate cert → trust → update hosts → start
	@echo -e "$(BOLD)$(CYAN)Running full setup...$(NC)"
	@$(MAKE) --no-print-directory cert
	@$(MAKE) --no-print-directory trust-cert
	@$(MAKE) --no-print-directory update-hosts
	@$(MAKE) --no-print-directory start
	@echo ""
	@echo -e "$(GREEN)✓ Setup complete! Traefik is running.$(NC)"

# ==================== LIFECYCLE ====================

start: ## Start Traefik in detached mode (alias: up)
	@echo -e "$(GREEN)Starting Traefik...$(NC)"
	@./bin/commands/start.sh

up: start ## Alias for start

stop: ## Stop Traefik (keeps containers, use 'start' to resume)
	@echo -e "$(YELLOW)Stopping Traefik...$(NC)"
	@./bin/commands/stop.sh

down: ## Stop and remove Traefik containers  [ARGS= for extra flags]
	@echo -e "$(RED)Removing Traefik containers...$(NC)"
	@./bin/commands/down.sh $(ARGS)

restart: ## Restart Traefik
	@echo -e "$(YELLOW)Restarting Traefik...$(NC)"
	@$(COMPOSE) restart
	@echo -e "$(GREEN)✓ Ready$(NC)"

# ==================== BUILD ====================

build: ## Build Traefik image
	@echo -e "$(GREEN)Building...$(NC)"
	@./bin/commands/build.sh

rebuild: ## Rebuild Traefik image without cache
	@echo -e "$(GREEN)Rebuilding without cache...$(NC)"
	@./bin/commands/build.sh --no-cache

# ==================== CLEAN ====================

clean: ## Prune unused images, volumes, networks and stopped containers
	@echo -e "$(RED)Cleaning up unused resources...$(NC)"
	@./bin/commands/clean.sh

clean-all: ## Full teardown: down with volumes + full prune
	@echo -e "$(RED)Full teardown...$(NC)"
	@./bin/commands/down.sh --volumes --rmi local --remove-orphans
	@./bin/commands/clean.sh --all
	@echo -e "$(RED)✓ Done$(NC)"

# ==================== OBSERVABILITY ====================

status: ## Show Traefik container status
	@$(COMPOSE) ps

logs: ## Tail logs  [make logs SERVICE]
	@$(COMPOSE) logs -f $(CMD_ARGS)

exec: ## Run a command in a container  [make exec SERVICE CMD...]
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

# ==================== SSL / CERTIFICATES ====================

cert: ## Generate self-signed TLS certificate from ssl/sites.conf
	@echo -e "$(CYAN)Generating certificate...$(NC)"
	@./bin/commands/update_cert.sh

trust-cert: ## Trust the certificate in the system keychain  [requires sudo]
	@echo -e "$(CYAN)Trusting certificate...$(NC)"
	@./bin/commands/trust_cert.sh

update-hosts: ## Sync /etc/hosts with DNS names from ssl/sites.conf  [requires sudo]
	@echo -e "$(CYAN)Updating /etc/hosts...$(NC)"
	@./bin/commands/update_hosts.sh

update-hosts-dry: ## Preview /etc/hosts changes without applying them
	@./bin/commands/update_hosts.sh --dry-run
