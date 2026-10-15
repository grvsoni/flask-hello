#!/bin/bash
set -e

# Read the version from VERSION file and trim whitespace
VERSION=$(cat VERSION | tr -d '[:space:]')
IMAGE_NAME="grvsoniharness/flask-counter"

build_image() {
    # Build the versioned image
    echo "Building image ${IMAGE_NAME}:v${VERSION}..."
    docker build -t "${IMAGE_NAME}:v${VERSION}" .

    # Tag as latest
    echo "Tagging as latest..."
    docker tag "${IMAGE_NAME}:v${VERSION}" "${IMAGE_NAME}:latest"
}

push_image() {
    echo "Logging in to Docker Hub..."
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    echo "Pushing version ${VERSION}..."
    docker push "${IMAGE_NAME}:v${VERSION}"
    echo "Pushing latest tag..."
    docker push "${IMAGE_NAME}:latest"
    echo "Successfully pushed ${IMAGE_NAME}:v${VERSION} and ${IMAGE_NAME}:latest"
}

case "${1:-}" in
    build) build_image ;;
    push) push_image ;;
    "") build_image; push_image ;;
    *) echo "Unknown command: $1 (expected 'build', 'push', or no argument)" >&2; exit 2 ;;
esac
