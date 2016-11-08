FROM jasonchw/alpine-consul:0.7.0

ARG JAVA_ALPINE_VERSION=8.92.14-r1
ARG ES_VER=2.4.1
ARG ES_URL=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch
ARG KOPF_VER=2.0

ENV LANG=C.UTF-8 \
    ES_DATA_NODE=true \
    ES_MASTER_NODE=true \
    ES_HEAP_SIZE=512m \
    ES_HOST=0.0.0.0 \
    ES_PATH_DATA=/opt/elasticsearch/data/ \
    ES_PATH_LOGS=/opt/elasticsearch/logs/ \
    ES_MLOCKALL=true

RUN apk update && apk upgrade && \
    apk add openjdk8-jre="$JAVA_ALPINE_VERSION" && \
    curl -sL ${ES_URL}/${ES_VER}/elasticsearch-${ES_VER}.tar.gz | tar xfz - -C /opt/ && \
    mv /opt/elasticsearch-${ES_VER} /opt/elasticsearch && \ 
    /opt/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/${KOPF_VER} && \
    rm -rf /var/cache/apk/* /tmp/* && \
    rm /etc/consul.d/consul-ui.json && \
    addgroup elasticsearch && \
    adduser -S -G elasticsearch elasticsearch && \
    chown -R elasticsearch:elasticsearch /opt/elasticsearch/

COPY etc/consul.d/elasticsearch.json              /etc/consul.d/
COPY etc/consul-templates/elasticsearch.yml.ctmpl /etc/consul-templates/elasticsearch.yml.ctmpl

COPY docker-entrypoint.sh   /usr/local/bin/docker-entrypoint.sh
COPY start-elasticsearch.sh /usr/local/bin/start-elasticsearch.sh
COPY healthcheck.sh         /usr/local/bin/healthcheck.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/start-elasticsearch.sh && \
    chmod +x /usr/local/bin/healthcheck.sh

EXPOSE 9200 9300

VOLUME ["/opt/elasticsearch/data/", "/opt/elasticsearch/logs/"]

ENTRYPOINT ["docker-entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=5s --retries=300 CMD /usr/local/bin/healthcheck.sh

