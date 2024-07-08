#!/bin/bash

setup_docker() {
    set -e
    PREV_PATH=$(pwd)
    cd btc-deploy/
    docker compose up -d --build || docker-compose up -d --build
    cd $PREV_PATH
    set +e
}

stop_docker() {
    PREV_PATH=$(pwd)
    cd btc-deploy/
    docker compose down || docker-compose down
    cd $PREV_PATH
}

setup_docker

BTC_ENDPOINT_READY=255
BTC_ENDPOINT_ELAPSED=0
BTC_ENDPOINT_SLEEP_SECONDS=5
BTC_ENDPOINT_TIMEOUT_SECONDS=60

while [ "$BTC_ENDPOINT_READY" -ne 0 ]; do
  curl --verbose --user test:password --data-binary '{"jsonrpc":"1.0","id":"curltest","method":"getblockchaininfo","params":[]}' -H 'content-type:text/plain;' http://127.0.0.1:18443/
  BTC_ENDPOINT_READY=$?
  echo "BITCOIN READY $BTC_ENDPOINT_READY"
  sleep $BTC_ENDPOINT_SLEEP_SECONDS
  let BTC_ENDPOINT_ELAPSED=$BTC_ENDPOINT_ELAPSED+$BTC_ENDPOINT_SLEEP_SECONDS
  if [ "$BTC_ENDPOINT_ELAPSED" -gt $BTC_ENDPOINT_TIMEOUT_SECONDS ]; then
    echo "Bitcoin endpoint not ready after $BTC_ENDPOINT_TIMEOUT_SECONDS seconds; aborting"
    exit 1
  fi
done

stop_docker
