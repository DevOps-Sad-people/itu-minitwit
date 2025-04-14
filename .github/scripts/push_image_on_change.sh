#!/bin/bash

set -e

IMAGE_NAME="${IMAGE_NAME}"
CONTEXT_PATH="${CONTEXT_PATH}"
REGISTRY_NAME="${REGISTRY_NAME}"
FULL_IMAGE="$REGISTRY_NAME/$IMAGE_NAME:latest"

echo "1. Building $IMAGE_NAME image..."
docker buildx build --cache-from=type=registry,ref=$FULL_IMAGE --load -t "$FULL_IMAGE" "$CONTEXT_PATH"
LOCAL_ID=$(docker images --filter=reference="$FULL_IMAGE" --format '{{.ID}}')

echo "2. Checking if image has changed..."
REMOTE_DIGEST=$(doctl registry repository list-tags "$IMAGE_NAME" --format Tag,ManifestDigest --no-header | grep '^latest' | awk '{print $2}' || true)

if [ -z "$REMOTE_DIGEST" ]; then
  echo "No remote image found — pushing new image..."
  docker push "$FULL_IMAGE"
  exit 0
fi

docker pull "$REGISTRY_NAME/$IMAGE_NAME@$REMOTE_DIGEST"
REMOTE_ID=$(docker images --filter=reference="$REGISTRY_NAME/$IMAGE_NAME@$REMOTE_DIGEST" --format '{{.ID}}')

echo "Local ID:  $LOCAL_ID"
echo "Remote ID: $REMOTE_ID"

if [ "$LOCAL_ID" = "$REMOTE_ID" ]; then
  echo "Image unchanged, skipping push."
else
  echo "Image has changed. Pushing..."
  docker push "$FULL_IMAGE"
fi