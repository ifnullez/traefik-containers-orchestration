SHELL := /bin/bash
COMPOSE := docker compose

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

.PHONY: help start stop restart down clean logs shell db-shell build rebuild

help: ## Show this help
	@echo "WordPress FPM-Alpine Management Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

start: ## Start all containers
	@echo -e "$(GREEN)Starting containers...$(NC)"
	@$(COMPOSE) up -d
	@echo -e "$(GREEN)✓ Containers started$(NC)"

stop: ## Stop all containers
	@echo -e "$(YELLOW)Stopping containers...$(NC)"
	@$(COMPOSE) stop
	@echo -e "$(YELLOW)✓ Containers stopped$(NC)"

restart: stop start ## Restart all containers

down: ## Stop and remove containers
	@echo -e "$(RED)Stopping and removing containers...$(NC)"
	@$(COMPOSE) down
	@echo -e "$(RED)✓ Containers removed$(NC)"

clean: ## Remove containers, volumes, and images
	@echo -e "$(RED)Cleaning up...$(NC)"
	@$(COMPOSE) down -v --rmi local
	@docker system prune -f
	@echo -e "$(RED)✓ Cleanup complete$(NC)"

logs: ## Show container logs (use: make logs or make logs s=nginx)
	@if [ -n "$(s)" ]; then \
		$(COMPOSE) logs -f $(s); \
	else \
		$(COMPOSE) logs -f; \
	fi

shell: ## Open shell in app container (use: make shell or make shell s=nginx)
	@if [ -n "$(s)" ]; then \
		docker exec -it $$(docker compose ps -q $(s)) /bin/sh; \
	else \
		docker exec -it $$(docker compose ps -q app) /bin/sh; \
	fi

db-shell: ## Open MySQL shell
	@docker exec -it $$(docker compose ps -q db) mysql -u root -p

build: ## Build containers
	@echo -e "$(GREEN)Building containers...$(NC)"
	@$(COMPOSE) build
	@echo -e "$(GREEN)✓ Build complete$(NC)"

rebuild: ## Rebuild containers without cache
	@echo -e "$(GREEN)Rebuilding containers...$(NC)"
	@$(COMPOSE) build --no-cache
	@echo -e "$(GREEN)✓ Rebuild complete$(NC)"

wp: ## Run WP-CLI command (use: make wp c="plugin list")
	@docker exec -it $$(docker compose ps -q app) wp $(c) --allow-root

status: ## Show container status
	@$(COMPOSE) ps

nginx-reload: ## Reload nginx configuration
	@docker exec -it $$(docker compose ps -q nginx) nginx -s reload
	@echo -e "$(GREEN)✓ Nginx reloaded$(NC)"

nginx-test: ## Test nginx configuration
	@docker exec -it $$(docker compose ps -q nginx) nginx -t

opcache-clear: ## Clear PHP opcache
	@docker exec -it $$(docker compose ps -q app) sh -c "php -r 'opcache_reset();'"
	@echo -e "$(GREEN)✓ Opcache cleared$(NC)"
