# Docker
Create the builder image:

`docker build -f Dockerfile.development --tag libavjs-builder .`

Run the builder:

`docker run --rm -v .:/src -u $(id -u):$(id -g) libavjs-builder make <args>`