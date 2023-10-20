#!/usr/bin/env bash

set -e  # stop execution on failure
set +x  # don't print executed command

echo "Loading environment variables"
export $(cat .env | xargs)

if [ -n "$BUILD_NO_CACHE" ] && [ "$BUILD_NO_CACHE" != 0 ]; then
  echo "'--no-cache' flag will be set for Docker builds"
  NO_CACHE_FLAG="--no-cache"
else
  NO_CACHE_FLAG=""
fi

echo "Building Docker image for NGINX Plus"
docker build $NO_CACHE_FLAG --secret id=nginx-key,src=$NGINX_REPO_KEY_FILE --secret id=nginx-crt,src=$NGINX_REPO_CERT_FILE -t $NGINX_PLUS_DOCKER_IMAGE .

if [ -n "$PUBLISH_IMAGE" ] && [ "$PUBLISH_IMAGE" != 0 ]; then
  echo "Publishing image $NGINX_PLUS_DOCKER_IMAGE"
  docker push $NGINX_PLUS_DOCKER_IMAGE
fi

if [ -n "$BUILD_UNPRIVILEGED" ] && [ "$BUILD_UNPRIVILEGED" != 0 ]; then
  echo "Building unprivileged Docker image for NGINX Plus"
  docker build $NO_CACHE_FLAG -f nginx-unprivileged.Dockerfile --build-arg NGINX_PLUS_IMAGE=$NGINX_PLUS_DOCKER_IMAGE -t $NGINX_PLUS_UNPRIVILEGED_DOCKER_IMAGE .

  if [ -n "$PUBLISH_IMAGE" ] && [ "$PUBLISH_IMAGE" != 0 ]; then
    echo "Publishing image $NGINX_PLUS_UNPRIVILEGED_DOCKER_IMAGE"
    docker push $NGINX_PLUS_UNPRIVILEGED_DOCKER_IMAGE
  fi
fi
