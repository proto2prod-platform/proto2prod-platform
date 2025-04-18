.PHONY: all bootstrap install-dev proto2prod-check test docs lint package

all: proto2prod-check

bootstrap:
	python -m pip install --upgrade pip
	pip install -r requirements.txt

install-dev:
	pip install -e common/
	pip install -r requirements.txt

proto2prod-check: test lint docs

test:
	pytest -q

lint:
	pre-commit run --all-files

docs:
	cd docs && make docs

package:
	python -m build
