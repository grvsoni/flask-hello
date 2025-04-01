#!/bin/bash

# Read the version from VERSION file and trim whitespace
VERSION=$(cat VERSION)
IMAGE_NAME="grvsoni/flask-counter"

docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

# Build the versioned image
echo "Building image ${IMAGE_NAME}:v${VERSION}..."
docker build -t "${IMAGE_NAME}:v${VERSION}" .
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# Tag as latest
echo "Tagging as latest..."
docker tag "${IMAGE_NAME}:v${VERSION}" "${IMAGE_NAME}:latest"

# Push both tags
echo "Pushing version ${VERSION}..."
docker push "${IMAGE_NAME}:v${VERSION}"
echo "Pushing latest tag..."
docker push "${IMAGE_NAME}:latest"

echo "Successfully pushed ${IMAGE_NAME}:v${VERSION} and ${IMAGE_NAME}:latest" 