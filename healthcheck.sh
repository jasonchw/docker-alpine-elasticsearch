#!/bin/bash

set -ex

CHECK_URL=http://127.0.0.1:9200

curl -sI ${CHECK_URL}
curl -s "${CHECK_URL}/_cat/health?status" | grep -E "green|yellow"

