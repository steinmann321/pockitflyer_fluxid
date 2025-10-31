PYTEST=pytest

.PHONY: test test-cov install-dev lint typecheck format pre-commit

install-dev:
	python -m pip install -r requirements.txt
	python -m pip install -r requirements-dev.txt

# Run tests with pytest
test:
	$(PYTEST) -q

# Run tests with coverage report
test-cov:
	$(PYTEST) --cov=config --cov=users -q --cov-report=term-missing

# Lint with ruff
lint:
	ruff check .

# Type check with mypy
typecheck:
	mypy config users

# Format with black
format:
	black .

# Install and run pre-commit hooks
pre-commit:
	pre-commit install && pre-commit run --all-files
