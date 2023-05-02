APP_COMMAND = python src/manage.py
FIX_LOC=src/seeds/
TEST_SETTINGS = 'app.settings.local'
PYTEST_CMD = py.test src -v -x -n auto
PYTEST_STDOUT_CMD = py.test src -s -v -x
PYTEST_COVERAGE_CMD = $(PYTEST_CMD) --no-cov-on-fail --cov=src --cov-config=src/.coveragerc
MINIMUM_COVERAGE = 90

# RUN

build-run-attached:
	# Run the development server attached showing the logs
	docker-compose up --build

stop-docker:
	docker-compose down -v

run:
	# Run the development server on background
	docker-compose up -d --build

# DJANGO MANAGEMENT

migrations:
	docker-compose exec app $(APP_COMMAND) makemigrations

collectstatic:
	docker-compose exec app $(APP_COMMAND) collectstatic


# QA

lint: run
	docker-compose exec app flake8 src --exclude=*/__init__.py,*/settings/*
	docker-compose exec app isort -c --diff src --profile black

lint-fix:
	black src
	isort --atomic src --profile black

test: run lint
	docker-compose exec app $(PYTEST_CMD)

coverage: run
	docker-compose exec app $(PYTEST_COVERAGE_CMD)

test-coverage: run
	# for diff only
	docker-compose exec app $(PYTEST_COVERAGE_CMD) --cov-report=xml
	$(GIT_FETCH_MASTER_CMD)
	diff-cover ./coverage.xml --compare-branch=main --fail-under $(MINIMUM_COVERAGE)

