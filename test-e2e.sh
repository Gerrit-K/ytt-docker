#!/usr/bin/env bash
# Runs upstream ytt's Go e2e tests against a docker image.
# Usage: test-e2e.sh [IMAGE] [YTT_VERSION]
set -eEuo pipefail

IMAGE=${1:-gerritk/ytt}
YTT_VERSION=${2:-develop}

WORKDIR=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$WORKDIR"' EXIT

git clone --quiet -c advice.detachedHead=false --depth 1 --branch "$YTT_VERSION" https://github.com/carvel-dev/ytt "$WORKDIR"
cd "$WORKDIR"

# Upstream tests run ../../ytt from test/e2e and pass absolute temp paths.
# The wrapper mounts the clone at its host path so both resolve inside docker.
DOCKER=$(command -v docker)
mkdir tmp
cat >./ytt <<WRAPPER
#!/usr/bin/env bash
exec "$DOCKER" run --rm -i \\
    -u "\$(id -u):\$(id -g)" \\
    \$(env | grep -E '^(STR|YAML)_VAL' | cut -f1 -d= | sed 's/^/-e /') \\
    -v "$WORKDIR":"$WORKDIR" -w "\$PWD" \\
    "$IMAGE" "\$@"
WRAPPER
chmod +x ./ytt

# Process substitution (/dev/fd/N) cannot cross into docker.
TMPDIR=$WORKDIR/tmp go test ./test/e2e/... -skip 'TestPipes/test_pipe_redirect'
