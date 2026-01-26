SHELL := /bin/bash
COMPOSE := $(shell ./bin/compose_cmd.sh)

ifeq ($(COMPOSE),error)
	$(error Compose command not found. Install docker-compose or podman-compose)
endif

# Colors
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
CYAN := \033[0;36m
NC := \033[0m

# Paths
BIN_DIR := ./bin/commands

.PHONY: help up down restart status logs build ssl ssl-trust hosts clean

# ==================== HELP ====================

help: ## Show this help
	@echo ""
	@echo -e "  $(CYAN)Traefik Proxy Management$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[0;32m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ==================== LIFECYCLE ====================

up: ## Start Traefik
	@echo -e "$(GREEN)Starting Traefik...$(NC)"
	@bash $(BIN_DIR)/start.sh
	@echo -e "$(GREEN)✓ Ready$(NC)"

down: ## Stop and remove containers
	@echo -e "$(RED)Removing containers...$(NC)"
	@bash $(BIN_DIR)/down.sh
	@echo -e "$(RED)✓ Done$(NC)"

stop: ## Stop containers
	@echo -e "$(YELLOW)Stopping Traefik...$(NC)"
	@bash $(BIN_DIR)/stop.sh
	@echo -e "$(YELLOW)✓ Stopped$(NC)"

restart: ## Restart containers
	@echo -e "$(YELLOW)Restarting...$(NC)"
	@bash $(BIN_DIR)/stop.sh
	@bash $(BIN_DIR)/start.sh
	@echo -e "$(GREEN)✓ Ready$(NC)"

status: ## Show container status
	@$(COMPOSE) ps

logs: ## Show Traefik logs
	@$(COMPOSE) logs -f

# ==================== BUILD & SETUP ====================

build: ssl hosts up ## Full setup (ssl + hosts + start)

# ==================== SSL ====================

ssl: ## Update SSL certificates
	@echo -e "$(GREEN)Updating SSL certificates...$(NC)"
	@bash $(BIN_DIR)/update_cert.sh
	@bash $(BIN_DIR)/trust_cert.sh
	@echo -e "$(GREEN)✓ SSL updated$(NC)"

ssl-trust: ## Trust SSL certificate only
	@echo -e "$(GREEN)Trusting SSL certificate...$(NC)"
	@bash $(BIN_DIR)/trust_cert.sh
	@echo -e "$(GREEN)✓ Done$(NC)"

# ==================== HOSTS ====================

hosts: ## Update hosts file
	@echo -e "$(GREEN)Updating hosts file...$(NC)"
	@bash $(BIN_DIR)/update_hosts.sh
	@echo -e "$(GREEN)✓ Done$(NC)"
