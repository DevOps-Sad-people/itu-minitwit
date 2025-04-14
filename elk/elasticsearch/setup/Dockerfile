ARG ELASTIC_VERSION

FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl

COPY ./entrypoint.sh /entrypoint.sh
COPY ./lib.sh /lib.sh
COPY ./roles /roles

CMD ["/entrypoint.sh"]