ARG ELASTIC_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTIC_VERSION}

ENTRYPOINT ["/setup/entrypoint.sh"]

# Add your elasticsearch plugins setup here
# Example: RUN elasticsearch-plugin install analysis-icu