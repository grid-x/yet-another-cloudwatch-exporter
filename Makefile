.DEFAULT_GOAL := build

GIT_BRANCH   ?= $(shell git rev-parse --abbrev-ref HEAD)
GIT_REVISION ?= $(shell git rev-parse --short HEAD)
VERSION      ?= $(GIT_BRANCH)-$(GIT_REVISION)
GO_LDFLAGS   := -X main.version=${VERSION}

IMAGE_BASE_URL := 108014196837.dkr.ecr.eu-central-1.amazonaws.com/gridx/yace
IMAGE_TAG := $(shell .buildkite/steps/docker_tag.sh)
IMAGE_URL := ${IMAGE_BASE_URL}:${IMAGE_TAG}

build:
	go build -v -ldflags "$(GO_LDFLAGS)" -o yace ./cmd/yace

test:
	go test -v -bench=^$$ -race -count=1 ./...

lint:
	golangci-lint run -v -c .golangci.yml

ci_test:
	@echo "--- Lint :mag:"
	docker compose --file docker-compose.buildkite.yml up --exit-code-from lint
	@echo "--- Test :test_tube:"
	docker compose --file docker-compose.buildkite.yml up --exit-code-from test
	@echo "--- Clean :broom:"
	docker compose --file docker-compose.buildkite.yml down -v --remove-orphans

ci_build:
	@echo "--- Building production image :package:"
	docker build -t ${IMAGE_URL} --no-cache -f Dockerfile .
	@echo "--- Pushing production image :envelope:"
	docker push ${IMAGE_URL}