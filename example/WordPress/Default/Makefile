SHELL := /bin/bash
COMPOSE := $(shell ./bin/compose_cmd.sh)

ifeq ($(COMPOSE),error)
	$(error Compose command not found. Install docker-compose or podman-compose)
endif

# Default containers
APP_CONTAINER := app
DB_CONTAINER := db

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
CYAN := \033[0;36m
NC := \033[0m

# Catch commands for wp, shell, logs, exec, command
ifneq ($(filter wp shell logs exec,$(firstword $(MAKECMDGOALS))),)
  CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(CMD_ARGS):;@:)
endif

.PHONY: help up down restart status logs shell exec build rebuild clean wp db opcache-clear

# ==================== HELP ====================

help: ## Show this help
	@echo ""
	@echo -e "  $(CYAN)Docker Management$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ==================== LIFECYCLE ====================

up: ## Start containers
	@echo -e "$(GREEN)Starting containers...$(NC)"
	@$(COMPOSE) up -d
	@echo -e "$(GREEN)✓ Ready$(NC)"

down: ## Stop and remove containers
	@echo -e "$(RED)Removing containers...$(NC)"
	@$(COMPOSE) down
	@echo -e "$(RED)✓ Done$(NC)"

restart: ## Restart containers
	@echo -e "$(YELLOW)Restarting...$(NC)"
	@$(COMPOSE) restart
	@echo -e "$(GREEN)✓ Ready$(NC)"

status: ## Show container status
	@$(COMPOSE) ps

# ==================== LOGS & SHELL ====================

logs: ## Show logs (make logs [container])
	@$(COMPOSE) logs -f $(CMD_ARGS)

shell: ## Open shell (make shell [container])
	@container="$(firstword $(CMD_ARGS))"; \
	container=$${container:-$(APP_CONTAINER)}; \
	docker exec -it $$($(COMPOSE) ps -q $$container) /bin/sh

exec: ## Run command in container (make exec <container> <command>)
	@container="$(firstword $(CMD_ARGS))"; \
	if [ -z "$$container" ]; then \
		echo -e "$(RED)Usage: make exec <container> <command>$(NC)"; \
		exit 1; \
	fi; \
	cmd="$(wordlist 2,$(words $(CMD_ARGS)),$(CMD_ARGS))"; \
	if [ -z "$$cmd" ]; then \
		echo -e "$(RED)Usage: make exec <container> <command>$(NC)"; \
		exit 1; \
	fi; \
	docker exec -it $$($(COMPOSE) ps -q $$container) $$cmd

# ==================== BUILD ====================

build: ## Build containers
	@echo -e "$(GREEN)Building...$(NC)"
	@$(COMPOSE) build
	@echo -e "$(GREEN)✓ Done$(NC)"

rebuild: ## Rebuild without cache
	@echo -e "$(GREEN)Rebuilding...$(NC)"
	@$(COMPOSE) build --no-cache
	@echo -e "$(GREEN)✓ Done$(NC)"

clean: ## Remove containers, volumes, images
	@echo -e "$(RED)Cleaning...$(NC)"
	@$(COMPOSE) down -v --rmi local
	@docker system prune -f
	@echo -e "$(RED)✓ Done$(NC)"

# ==================== WORDPRESS ====================

wp: ## Run WP-CLI (make wp <command>)
	@if [ -z "$(CMD_ARGS)" ]; then \
		echo -e "$(RED)Usage: make wp <command>$(NC)"; \
		echo -e "Example: make wp plugin list"; \
		exit 1; \
	fi
	@docker exec -it $$($(COMPOSE) ps -q $(APP_CONTAINER)) wp $(CMD_ARGS) --allow-root

# ==================== PHP ====================

opcache-clear: ## Clear PHP opcache
	@docker exec $$($(COMPOSE) ps -q $(APP_CONTAINER)) php -r "opcache_reset();" 2>/dev/null || \
		echo -e "$(YELLOW)Opcache not enabled or already clear$(NC)"
	@echo -e "$(GREEN)✓ Done$(NC)"
