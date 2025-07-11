FROM ghcr.io/forestracks/javaj9:8

USER root

WORKDIR /home/container

RUN apt-get update && apt-get install -y curl jq && apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]