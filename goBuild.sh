#!/usr/bin/env bash
#

set -e

function build_container() {
    source Dockerfile.input

if [ -z $GO_PIPELINE_LABEL ]; then
      # building without GoCD
      docker build --pull -t ubirch-bigchaindb-service:vmanual .
      docker tag ubirch-bigchaindb-service:vmanual tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:vmanual
  else
      # build with GoCD
      docker build --pull -t ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL --build-arg GO_PIPELINE_NAME=$GO_PIPELINE_NAME \
      --build-arg GO_PIPELINE_LABEL=$GO_PIPELINE_LABEL \
      --build-arg GO_PIPELINE_COUNTER=$GO_PIPELINE_COUNTER  .

      docker tag ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL
  fi

  if [ $? -ne 0 ]; then
    echo "Docker build failed"
    exit 1
  fi

  # push Docker image
  if [ -z $GO_PIPELINE_LABEL ]; then
    docker push tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:vmanual
  else
    docker push tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL
  fi
  if [ $? -ne 0 ]; then
    echo "Docker push failed"
    exit 1
  fi

}

function container_tag () {
    docker pull tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL
    docker tag tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:latest
    docker push tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:latest

}

function container_tag_stable () {
    docker pull tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL
    docker tag tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:v$GO_PIPELINE_LABEL tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:stable
    docker push tracklecontainerregistry-on.azurecr.io/ubirch-bigchaindb-service:stable

}

case "$1" in
    containerbuild)
        build_container
        ;;
    containertag)
        container_tag
        ;;
    containertagstable)
        container_tag_stable
        ;;
    *)
        echo "Usage: $0 { containerbuild | containertag | containertagstable }"
        exit 1
esac

exit 0
