#!/bin/bash

set -e

source .VERSION

IMAGE_NAME="${IMAGE_NAME}"
CONTEXT_PATH="${CONTEXT_PATH}"
VERSION_VAR_NAME=$(echo "${IMAGE_NAME^^}")_VERSION
VERSION="${!VERSION_VAR_NAME}"
REGISTRY_NAME="${REGISTRY_NAME}"

echo "Building $IMAGE_NAME:$VERSION image..."
VERSION_TAG="$REGISTRY_NAME/$IMAGE_NAME:$VERSION"
LATEST_TAG="$REGISTRY_NAME/$IMAGE_NAME:latest"
docker build -t "$VERSION_TAG" -t "$LATEST_TAG" "$CONTEXT_PATH"

echo "Checking $IMAGE_NAME:$VERSION in registry..."
if doctl registry repository list-tags "$IMAGE_NAME" --format Tag --no-header | grep -q "^$VERSION$"; then
  echo "Image already exists, skipping push."
  exit 0
fi

echo "Pushing $VERSION_TAG to registry..."
docker push "$VERSION_TAG"
docker push "$LATEST_TAG"