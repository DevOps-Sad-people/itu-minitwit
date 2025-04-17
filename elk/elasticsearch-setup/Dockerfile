ARG ELASTIC_VERSION

FROM ubuntu:25.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl=8.12.1-3ubuntu1 \
    && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
COPY ./lib.sh /lib.sh
COPY ./roles /roles

CMD ["/entrypoint.sh"]