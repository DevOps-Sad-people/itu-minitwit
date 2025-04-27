#!/bin/bash

set -e

IMAGE_NAME="${IMAGE_NAME}"
TAG_NAME="${TAG}"
CONTEXT_PATH="${CONTEXT_PATH}"
REGISTRY_NAME="${REGISTRY_NAME}"

echo "Checking for changes in the image files..."
#if ! git rev-parse HEAD~1 >/dev/null 2>&1 || ! git diff --quiet HEAD HEAD~1 -- $CONTEXT_PATH; then
echo "Building $IMAGE_NAME:$TAG_NAME image..."
VERSION_TAG="$REGISTRY_NAME/$IMAGE_NAME:$TAG_NAME"
docker build -t "$VERSION_TAG" "$CONTEXT_PATH"

echo "Pushing $IMAGE_NAME:$TAG_NAME to registry..."
docker push "$VERSION_TAG"
#else
echo "No changes in image files, skipping push."
#fi