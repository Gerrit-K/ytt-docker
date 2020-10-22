FROM golang:1.13-buster as build

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
 && sed -i 's/localhost/0.0.0.0/' ./pkg/cmd/website.go \
 && sed -i 's/checkHTTPs := true/checkHTTPs := false/' ./pkg/website/server.go \
 && ./hack/build.sh
# The "hacks" above are necessary because the 'website' server would otherwise
# 1. only listen to localhost, not accepting connections from outside the container
# 2. force a HTTPS redirect


FROM busybox:1.31.1

COPY --from=build /go/src/github.com/k14s/ytt/ytt /usr/bin/ytt
WORKDIR /workspace
ENTRYPOINT ["/usr/bin/ytt"]
CMD ["-h"]
