.PHONY: default builder runtime
default: builder runtime
builder: builder-rust/.built
runtime: runtime-rust/.built

builder-rust/.built: builder-rust/Dockerfile
	@cd builder-rust ; docker build -t rust-base:alpine . && touch .built

runtime-rust/.built: runtime-rust/Dockerfile
	@cd runtime-rust ; docker build -t rust-runtime:alpine . && touch .built

.PHONY: clean
	rm builder-rust/.built
	rm runtime-rust/.built

APP=test-app

.PHONY: test test-build

SRC_FILES:=$(shell find test/test-app/ -type f)
PWD:=$(shell pwd)

test-build: builder-rust/.built $(SRC_FILES)
	@echo "=== Building binary ==="
	@mkdir -p test/build
	@mkdir -p test/build/cache
	@mkdir -p test/build/app
	cd test ; \
	  docker build \
	    --build-arg https_proxy=$(https_proxy) \
	    --build-arg http_proxy=$(http_proxy) \
	    -t $(APP):build . -f Dockerfile.build
	@echo
	@echo "=== Extracting .cargo ==="
	@[ -d test/build/cache/.cargo ] || \
		docker run --rm $(APP):build tar -c -C /root -f - .cargo | \
		tar Cxf test/build/cache -
	@echo "=== Extracting target/ ==="
	@[ -d test/build/app/release ] || \
		docker run --rm $(APP):build tar -c -C /app/target -f - release | \
		tar Cxf test/build/app -

test: test-build runtime-rust/.built 
	@echo "=== Creating image ==="
	@cd test ; \
	  docker create --name extract $(APP):build && \
	  docker cp extract:/app/target/release/$(APP) ./build/app/ && \
	  docker rm -f extract
	@cd test ; \
      docker build --no-cache -t $(APP):latest .

test-run:
	docker run -ti --init --rm -p 8080:8080 $(APP):latest