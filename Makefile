PROJECT=hello-web

help:
	@echo "make

# build-image:
# 	docker build -f Dockerfile.build .

builder-image-dev:
	@echo
	@echo "=== Recreating Debug Build Environment ============================="
	docker build -f Dockerfile.dev-builder -t $(PROJECT):builder-dev .

builder-image-release:
	@echo
	@echo "=== Recreating RELEASE Build Environment ==========================="
	docker build -f Dockerfile.release-builder -t $(PROJECT):builder-release .
	# TODO: Push to a registry for caching

build:
	@echo
	@echo "=== Running Debug Build ============================================"
	# TODO: Pull builder image from registry or build it
	docker build -f Dockerfile.dev -t $(PROJECT):latest-dev .

build-release:
	@echo
	@echo "=== Running RELEASE Build =========================================="
	docker build -f Dockerfile.release -t $(PROJECT):latest-release .

TEST_PORT=3000

run:
	@echo "==> App available at http://localhost:$(TEST_PORT)"
	@docker run --rm -p $(TEST_PORT):$(TEST_PORT) -e PORT=$(TEST_PORT) -e BIND_ADDR=0.0.0.0 -it $(PROJECT):latest-dev

runtime-base:
	@echo
	@echo "=== Recreating Runtime Environment ================================="
	docker build -f Dockerfile.runtime-base -t $(PROJECT):runtime-base .

runtime:
	@echo
	@echo "=== Bulding Production Image ======================================="
	docker create --name extract $(PROJECT):latest-release
	docker cp extract:/target/release/$(PROJECT) ./$(PROJECT)
	docker rm -f extract

	docker build --no-cache -f Dockerfile.run -t $(PROJECT):latest .

release-quick: build-release runtime

release-full: builder-image-release build-release runtime

run-opt:
	@docker run --rm -p $(TEST_PORT):$(TEST_PORT) -e PORT=$(TEST_PORT) -e BIND_ADDR=0.0.0.0 -it $(PROJECT):latest
