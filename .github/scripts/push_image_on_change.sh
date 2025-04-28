#!/bin/bash

set -e

IMAGE_NAME="${IMAGE_NAME}"
TAG_NAME="${TAG}"
CONTEXT_PATH="${CONTEXT_PATH}"
REGISTRY_NAME="${REGISTRY_NAME}"
CURRENT_COMMIT_SHA="${COMMIT_SHA}"

build_and_push() {
    echo "Building $IMAGE_NAME:$TAG_NAME image..."

    CURRENT_COMMIT_TAG="$REGISTRY_NAME/$IMAGE_NAME:$CURRENT_COMMIT_SHA"
    MAIN_TAG="$REGISTRY_NAME/$IMAGE_NAME:$TAG_NAME"
    docker build -t "$CURRENT_COMMIT_TAG" -t "$MAIN_TAG" "$CONTEXT_PATH"

    echo "Pushing $IMAGE_NAME:$TAG_NAME to registry..."

    docker push "$CURRENT_COMMIT_TAG"
    docker push "$MAIN_TAG"
}

DIGEST=$(doctl registry repository list-tags "$IMAGE_NAME" --format Tag,ManifestDigest --no-header 2>/dev/null | tr -s ' ' | grep "^$TAG_NAME " | cut -d ' ' -f2)
if [ -z "$DIGEST" ]; then
    build_and_push

    exit 0
fi

LAST_COMMIT_SHA=$(doctl registry repository list-tags "$IMAGE_NAME" --format Tag,ManifestDigest --no-header 2>/dev/null | tr -s ' ' | grep " $DIGEST$" | grep -v "^$TAG_NAME " | cut -d ' ' -f1)
if [ -z "$LAST_COMMIT_SHA" ]; then
    build_and_push

    exit 0
fi

echo "Image already exists in registry."
echo "Checking for changes in the image files..."

if ! git diff --quiet "$CURRENT_COMMIT_SHA" "$LAST_COMMIT_SHA" -- "$CONTEXT_PATH" 2>/dev/null; then
    build_and_push
else
    echo "No changes in image files, skipping build & push."
fi