FROM golang:1.13-buster as build

ARG YTT_VERSION=develop
RUN echo building ytt $YTT_VERSION \
 && git clone \
        --branch "${YTT_VERSION}" \
        --single-branch \
        --depth 1 \
        https://github.com/k14s/ytt \
        ./src/github.com/k14s/ytt
WORKDIR /go/src/github.com/k14s/ytt
RUN CGO_ENABLED=0 go build -o ytt ./cmd/ytt/...

FROM busybox:1.31.1

COPY --from=build /go/src/github.com/k14s/ytt/ytt /usr/bin/ytt
WORKDIR /workspace
ENTRYPOINT ["/usr/bin/ytt"]
CMD ["-h"]
