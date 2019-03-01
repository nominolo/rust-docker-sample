# Example of Rust & Docker

Basic ideas:

 * We use a builder base image that caches the libraries built
 * The application is built using that builder base image
 * The productive image only contains the program binary and required runtime
   dependencies.

# Workflow

First time & when dependencies changed drastically

```bash
# This can take a while
make builder-image-dev
make builder-image-release
```

Development workflow

```bash
make build && make run
```

Release workflow

```bash
# Run this the first time, and when you change Dockerfile.runtime-base
make runtime-base

make build-release
make runtime

make run-opt
```

# TODO:

 * auto-rebuild builder image if Cargo.toml changed
 * optionally support using a volume (a docker image is easier to cache in many
   CI environments)

