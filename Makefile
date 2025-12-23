.PHONY: help install test test-unit test-local test-service1 test-service2 test-external-api clean validate build

# Colors for output
GREEN := \033[0;32m
BLUE := \033[0;34m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo '$(BLUE)Available targets:$(NC)'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

install: ## Install development dependencies
	@echo '$(BLUE)Installing development dependencies...$(NC)'
	@python3 -m pip install --upgrade pip
	@python3 -m pip install -r requirements-dev.txt
	@echo '$(GREEN)✓ Dependencies installed$(NC)'

test: test-unit ## Run all tests (unit + validation)
	@echo '$(GREEN)All tests completed!$(NC)'

test-unit: ## Run unit tests with Python (no pytest required)
	@echo '$(BLUE)Running unit tests...$(NC)'
	@python3 run-simple-tests.py

test-pytest: ## Run unit tests with pytest (requires pytest installed)
	@echo '$(BLUE)Running pytest unit tests...$(NC)'
	@./run-unit-tests.sh

test-coverage: ## Run unit tests with coverage report
	@echo '$(BLUE)Running tests with coverage...$(NC)'
	@./run-unit-tests.sh -c

test-local: ## Test Lambda functions locally with SAM CLI (requires Docker)
	@echo '$(BLUE)Testing Lambda functions locally...$(NC)'
	@./run-local-invoke.sh

test-service1: ## Test service1 Lambda locally
	@echo '$(BLUE)Testing service1...$(NC)'
	@./run-local-invoke.sh service1

test-service2: ## Test service2 Lambda locally
	@echo '$(BLUE)Testing service2...$(NC)'
	@./run-local-invoke.sh service2

test-external-api: ## Test external-api Lambda locally
	@echo '$(BLUE)Testing external-api...$(NC)'
	@./run-local-invoke.sh external-api

validate: ## Validate Lambda function code syntax
	@echo '$(BLUE)Validating Python syntax...$(NC)'
	@python3 -m py_compile service1/src/app.py
	@python3 -m py_compile service2/src/app.py
	@python3 -m py_compile external-api/src/app.py
	@echo '$(GREEN)✓ All Lambda functions are valid$(NC)'

build: ## Build Lambda functions with SAM
	@echo '$(BLUE)Building Lambda functions...$(NC)'
	@cd service1 && sam build
	@cd service2 && sam build
	@cd external-api && sam build
	@echo '$(GREEN)✓ Build completed$(NC)'

start-api-service1: ## Start local API Gateway for service1 (port 3000)
	@echo '$(BLUE)Starting local API for service1 on port 3000...$(NC)'
	@./run-local-api.sh service1 3000

start-api-service2: ## Start local API Gateway for service2 (port 3001)
	@echo '$(BLUE)Starting local API for service2 on port 3001...$(NC)'
	@./run-local-api.sh service2 3001

start-api-external: ## Start local API Gateway for external-api (port 3002)
	@echo '$(BLUE)Starting local API for external-api on port 3002...$(NC)'
	@./run-local-api.sh external-api 3002

clean: ## Clean up generated files
	@echo '$(BLUE)Cleaning up...$(NC)'
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name ".coverage" -delete 2>/dev/null || true
	@find . -type d -name ".aws-sam" -exec rm -rf {} + 2>/dev/null || true
	@echo '$(GREEN)✓ Cleanup completed$(NC)'

quick-test: validate test-unit ## Quick test: validate syntax and run unit tests
	@echo '$(GREEN)Quick test completed successfully!$(NC)'
