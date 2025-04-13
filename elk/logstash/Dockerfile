ARG ELASTIC_VERSION

FROM docker.elastic.co/logstash/logstash:8.17.3

COPY config/logstash.yml /usr/share/logstash/config/logstash.yml
COPY pipeline /usr/share/logstash/pipeline