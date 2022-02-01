#!/bin/sh

set -ex

# Fetch helm dependencies. Currently there is no way to build helm chart dependencies recursively
# (https://github.com/helm/helm/issues/2247), so until that issue is fixed we are fetching them here
rm ./humio-helm-charts/charts/humio-core/charts/*.tgz - removed because of none here
helm repo add confluentinc https://humio.github.io/cp-helm-charts
helm repo update
pushd ./humio-helm-charts/charts/humio-core && helm dep up; popd
pushd ./humio-helm-charts/charts/humio-metrics && helm dep up; popd

# Remove any existing indexes
find . -iname index.yaml | grep -v docs | xargs rm

# Move existing releases to the charts directory so they can be re-indexed with proper URLs
rm -rf /tmp/docs.save && mkdir /tmp/docs.save
find docs/ -name '*.tgz' -maxdepth 1 -exec mv {} /tmp/docs.save/ \;

helm package .

mv /tmp/docs.save/*.tgz ./ && rmdir /tmp/docs.save

helm repo index . && mv index.yaml ./docs

# Move all the charts to the docs so they can be served by github pages
find . -name '*.tgz' -mindepth 1 -maxdepth 1 -exec mv {} docs/ \;
