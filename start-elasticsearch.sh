#!/bin/bash

set -e
ES_BIN=/opt/elasticsearch/bin/elasticsearch

if [ -z ${ES_NODE_NAME} ]; then
    export ES_NODE_NAME=$(hostname -f)
fi

if [ "X${ES_PUB_HOST}" == "X" ]; then
    export ES_PUB_HOST=$(ip -o -4 addr list ${CONSUL_BIND_INTERFACE} | head -n1 | awk '{print $4}' | cut -d/ -f1)
fi

set -- gosu elasticsearch ${ES_BIN}

sleep 5
consul-template -consul localhost:8500 -once -template "/etc/consul-templates/elasticsearch.yml.ctmpl:/opt/elasticsearch/config/elasticsearch.yml"

chown -R elasticsearch:elasticsearch /opt/elasticsearch/

exec "$@"

