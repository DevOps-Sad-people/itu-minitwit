ARG ELASTIC_VERSION

FROM ubuntu:25.04

RUN apt-get update && apt-get install -y curl=8.12.1-3ubuntu1

COPY ./entrypoint.sh /entrypoint.sh
COPY ./lib.sh /lib.sh
COPY ./roles /roles

CMD ["/entrypoint.sh"]