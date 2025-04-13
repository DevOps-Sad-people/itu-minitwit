ARG ELASTIC_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:8.17.3

COPY setup/entrypoint.sh /entrypoint.sh
COPY setup/lib.sh /lib.sh
COPY setup/roles /roles
COPY config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/entrypoint.sh"]