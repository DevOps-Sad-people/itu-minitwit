#!/bin/bash

set -e

IMAGE_NAME="${IMAGE_NAME}"
REF_NAME=${REF_NAME}
CONTEXT_PATH="${CONTEXT_PATH}"
REGISTRY_NAME="${REGISTRY_NAME}"

echo "Checking for changes in the image files..."
if ! git rev-parse HEAD~1 >/dev/null 2>&1 || ! git diff --quiet HEAD HEAD~1 -- $CONTEXT_PATH; then
  echo "Building $IMAGE_NAME:$REF_NAME image..."
  VERSION_TAG="$REGISTRY_NAME/$IMAGE_NAME:$REF_NAME"
  LATEST_TAG="$REGISTRY_NAME/$IMAGE_NAME:latest"
  docker build -t "$VERSION_TAG" -t "$LATEST_TAG" "$CONTEXT_PATH"

  echo "Pushing $IMAGE_NAME:$REF_NAME to registry..."
  docker push "$VERSION_TAG"
  docker push "$LATEST_TAG"
else
  echo "No changes in image files, skipping push."
fi