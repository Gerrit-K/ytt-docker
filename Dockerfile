FROM golang:1.23.2-bookworm AS build

ARG YTT_VERSION=develop
WORKDIR /go/src/github.com/k14s/ytt
RUN echo building ytt $YTT_VERSION \
 && git clone \
        --branch "${YTT_VERSION}" \
        https://github.com/carvel-dev/ytt \
        . \
 && apt-get update && apt-get install -y --no-install-recommends zip=3.0* \
 && ./hack/build.sh


FROM busybox:1.37

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/src/github.com/k14s/ytt/ytt /usr/bin/ytt
WORKDIR /workspace
ENTRYPOINT ["/usr/bin/ytt"]
CMD ["-h"]
