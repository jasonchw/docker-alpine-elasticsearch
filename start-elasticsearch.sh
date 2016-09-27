#!/bin/bash

set -e
ES_BIN=/opt/elasticsearch/bin/elasticsearch

if [ -z ${ES_NODE_NAME} ]; then
    export ES_NODE_NAME=$(hostname -f)
fi

set -- gosu elasticsearch ${ES_BIN}

sleep 5
consul-template -consul localhost:8500 -once -template "/etc/consul-templates/elasticsearch.yml.ctmpl:/opt/elasticsearch/config/elasticsearch.yml"

exec "$@"

