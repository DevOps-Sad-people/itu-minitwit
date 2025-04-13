ARG ELASTIC_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:8.17.3

COPY ./entrypoint.sh /entrypoint.sh
COPY ./lib.sh /lib.sh
COPY ./roles /roles

CMD ["/entrypoint.sh"]