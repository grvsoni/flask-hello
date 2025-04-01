#!/bin/bash

# Exit on any error
set -e

# Configuration
REPO_URL="https://github.com/grvsoni/flask-hello.git"  # Replace with your repo URL
IMAGE_NAME="grvsoni/flask-counter"
TEMP_DIR=$(mktemp -d)

echo "==> Creating temporary build directory: ${TEMP_DIR}"

# Cleanup function
cleanup() {
    echo "==> Cleaning up temporary directory"
    rm -rf "${TEMP_DIR}"
}

# Register cleanup function on script exit
trap cleanup EXIT

echo "==> Cloning repository"
git clone --depth 1 -b main "${REPO_URL}" "${TEMP_DIR}"
cd "${TEMP_DIR}"

# Read version from VERSION file
VERSION=$(cat VERSION | tr -d '[:space:]')
echo "==> Building version: ${VERSION}"

# Build the image
echo "==> Building Docker image"
docker build -t "${IMAGE_NAME}:v${VERSION}" .
docker tag "${IMAGE_NAME}:v${VERSION}" "${IMAGE_NAME}:latest"

# Push the images
echo "==> Pushing Docker images"
docker push "${IMAGE_NAME}:v${VERSION}"
docker push "${IMAGE_NAME}:latest"

echo "==> Successfully published:"
echo "    - ${IMAGE_NAME}:v${VERSION}"
echo "    - ${IMAGE_NAME}:latest"

# Print verification steps
echo "
Deployment completed successfully!
To verify the deployment:

1. Pull and run the new image:
   docker pull ${IMAGE_NAME}:v${VERSION}
   docker run -d -p 3000:3000 --name flask-app ${IMAGE_NAME}:v${VERSION}

2. Access the application:
   http://localhost:3000

3. Check the version on Docker Hub:
   https://hub.docker.com/r/grvsoni/flask-counter/tags
" 