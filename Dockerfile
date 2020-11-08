FROM golang:1.15-buster AS build

ARG YTT_VERSION=develop
WORKDIR /go/src/github.com/k14s/ytt
RUN echo building ytt $YTT_VERSION \
 && git clone \
        --branch "${YTT_VERSION}" \
        --single-branch \
        --depth 1 \
        https://github.com/k14s/ytt \
        . \
 && apt-get update && apt-get install -y --no-install-recommends zip=3.0* \
 && ./hack/build.sh


FROM busybox:1.32

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/src/github.com/k14s/ytt/ytt /usr/bin/ytt
WORKDIR /workspace
ENTRYPOINT ["/usr/bin/ytt"]
CMD ["-h"]
