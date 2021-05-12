#!/usr/bin/env bash

set -eEo pipefail

OLD_PWD=$PWD
function cleanup() {
    cd $OLD_PWD
}
trap cleanup EXIT INT TERM

IMAGE_NAME=${1:gerritk/ytt}

cd $(mktemp -d)

git clone https://github.com/vmware-tanzu/carvel-ytt .

# create a "fake" ytt binary
cat >./ytt <<EOF
#!/usr/bin/env bash
docker run --rm \
    -u \$(id -u \$USER):\$(id -g \$USER) \
    \$(env | grep -E 'STR_VAL|YAML_VAL' | cut -f1 -d= | sed 's/^/-e /') \
    -iv "\${PWD}":/workspace $IMAGE_NAME "\$@"
EOF
chmod +x ./ytt

# patch the e2e tests:
#  - remove the ./hack/build.sh call
#  - remove the pipe tests (they won't work with docker)
git apply --whitespace=fix <<'EOF'
diff --git a/hack/test-e2e.sh b/hack/test-e2e.sh
index 6a6fa4c..dd42f32 100755
--- a/hack/test-e2e.sh
+++ b/hack/test-e2e.sh
@@ -2,8 +2,6 @@
 
 set -e -x
 
-./hack/build.sh
-
 mkdir -p ./tmp
 
 # check stdin reading
@@ -51,9 +49,6 @@ diff <(./ytt -f examples/overlay-not-matcher)           examples/overlay-not-mat
 # test pipe stdin
 diff <(cat examples/k8s-relative-rolling-update/config.yml | ./ytt -f-) examples/k8s-relative-rolling-update/expected.txt
 
-# test pipe redirect (on Linux, pipe is symlinked)
-diff <(./ytt -f pipe.yml=<(cat examples/k8s-relative-rolling-update/config.yml)) examples/k8s-relative-rolling-update/expected.txt
-
 # test data values
 diff <(./examples/data-values/run.sh) examples/data-values/expected.txt
 
EOF

# run the e2e tests
hack/test-e2e.sh

