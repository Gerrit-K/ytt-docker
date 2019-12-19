FROM debian:bullseye-slim

ARG YTT_VERSION
ADD https://github.com/k14s/ytt/releases/download/${YTT_VERSION}/ytt-linux-amd64 /usr/bin/ytt

RUN chmod +x /usr/bin/ytt && mkdir /workspace

WORKDIR /workspace

ENTRYPOINT ["/usr/bin/ytt"]

