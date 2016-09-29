FROM jasonchw/alpine-consul

ARG JAVA_ALPINE_VERSION=8.92.14-r1
ARG ES_VER=2.3.5
ARG ES_URL=https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch

ENV LANG=C.UTF-8 \
    ES_DATA_NODE=true \
    ES_MASTER_NODE=true \
    ES_HEAP_SIZE=512m \
    ES_NET_HOST=0.0.0.0 \
    ES_PATH_DATA=/opt/elasticsearch/data/ \
    ES_PATH_LOGS=/opt/elasticsearch/logs/ \
    ES_MLOCKALL=true

RUN apk update && apk upgrade && \
    apk add openjdk8-jre="$JAVA_ALPINE_VERSION" && \
    apk add curl nmap && \
    curl -sL ${ES_URL}/${ES_VER}/elasticsearch-${ES_VER}.tar.gz |tar xfz - -C /opt/ && \
    mv /opt/elasticsearch-${ES_VER} /opt/elasticsearch && \
    rm -rf /var/cache/apk/* /tmp/*

RUN addgroup elasticsearch && \
    adduser -S -G elasticsearch elasticsearch

COPY etc/consul.d/elasticsearch.json              /etc/consul.d/
COPY etc/consul-templates/elasticsearch.yml.ctmpl /etc/consul-templates/elasticsearch.yml.ctmpl

COPY docker-entrypoint.sh   /usr/local/bin/docker-entrypoint.sh
COPY start-elasticsearch.sh /usr/local/bin/start-elasticsearch.sh
COPY healthcheck.sh         /usr/local/bin/healthcheck.sh

RUN chown -R elasticsearch:elasticsearch /opt/elasticsearch/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/start-elasticsearch.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

RUN /opt/elasticsearch/bin/plugin install mobz/elasticsearch-head

EXPOSE 9200 9300

ENTRYPOINT ["docker-entrypoint.sh"]

HEALTHCHECK --interval=5s --timeout=5s --retries=300 CMD /usr/local/bin/healthcheck.sh

