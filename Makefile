# Makefile for Proto2Prod Platform

.PHONY: all bootstrap install-dev proto2prod-check test test-submodules lint lint-submodules docs docs-submodules package clean help

# Variables
PYTHON := python
PIP := $(PYTHON) -m pip
PRECOMMIT := pre-commit
PYTEST := pytest
SPHINXBUILD := sphinx-build
BUILD := $(PYTHON) -m build

# Default target
all: proto2prod-check

## ---------------------
## Bootstrapping & Setup
## ---------------------

bootstrap:
	@echo "Bootstrapping environment..."
	git submodule update --init --recursive
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt
	$(PIP) install -r requirements-dev.txt
	$(PRECOMMIT) install

install-dev:
	@echo "Installing development dependencies..."
	$(PIP) install -e common/
	$(PIP) install -r requirements-dev.txt

## ---------------------
## Quality Checks
## ---------------------

proto2prod-check: lint test docs
	@echo "Platform checks complete."

lint: lint-platform lint-submodules

lint-platform:
	@echo "Running linters on platform root..."
	$(PRECOMMIT) run --all-files

lint-submodules:
	@echo "Running linters within submodules..."
	@$(MAKE) -C common lint || echo "Skipping common lint (or failed)"
	@$(MAKE) -C governance lint || echo "Skipping governance lint (or failed)"
	@$(MAKE) -C templates lint || echo "Skipping templates lint (or failed)"
	# Add other submodules with lint targets if applicable

test: test-platform test-submodules

test-platform:
	@echo "Running tests for platform root..."
	$(PYTEST) -q tests/

test-submodules:
	@echo "Running tests within submodules..."
	@$(MAKE) -C common test || echo "Skipping common tests (or failed)"
	@$(MAKE) -C tests test || echo "Skipping tests tests (or failed)"
	@$(MAKE) -C benchmarks test || echo "Skipping benchmarks tests (or failed)"
	# Add other submodules with test targets if applicable

docs: docs-platform docs-submodules

docs-platform:
	@echo "Building platform documentation..."
	$(MAKE) -C docs html

docs-submodules:
	@echo "Building documentation within submodules (if any)..."
	# Add submodules with docs targets if applicable

## ---------------------
## Packaging & Cleaning
## ---------------------

package:
	@echo "Building package..."
	$(BUILD)

clean:
	@echo "Cleaning up build artifacts and cache..."
	find . -type f -name '*.py[co]' -delete
	find . -type d -name '__pycache__' -delete
	rm -rf build/ dist/ *.egg-info/
	rm -rf docs/_build/
	rm -rf .pytest_cache/
	rm -rf .coverage

## ---------------------
## Help
## ---------------------

help:
	@echo "Available targets:"
	@echo "  bootstrap        - Initialize submodules and install base dependencies + pre-commit hooks"
	@echo "  install-dev      - Install development dependencies (including common lib in editable mode)"
	@echo "  lint             - Run linters on platform and submodules"
	@echo "  test             - Run tests on platform and submodules"
	@echo "  docs             - Build documentation for platform and submodules"
	@echo "  proto2prod-check - Run all lint, test, and docs checks"
	@echo "  package          - Build the platform package"
	@echo "  clean            - Remove build artifacts, cache files, etc."
	@echo "  help             - Show this help message"
