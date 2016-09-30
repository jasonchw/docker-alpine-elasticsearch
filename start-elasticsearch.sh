#!/bin/bash

set -e
ES_BIN=/opt/elasticsearch/bin/elasticsearch

if [ -z ${ES_NODE_NAME} ]; then
    export ES_NODE_NAME=$(hostname -f)
fi

if [ "X${ES_PUB_HOST}" == "X" ]; then
    export ES_PUB_HOST=$(ip -o -4 add | egrep '16|24' | head -n1 | egrep -o '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
fi

set -- gosu elasticsearch ${ES_BIN}

sleep 5
consul-template -consul localhost:8500 -once -template "/etc/consul-templates/elasticsearch.yml.ctmpl:/opt/elasticsearch/config/elasticsearch.yml"

chown -R elasticsearch:elasticsearch /opt/elasticsearch/

exec "$@"

