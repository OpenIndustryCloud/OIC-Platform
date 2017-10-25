#!/bin/bash

set -e -u -x

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
echo $DIR
/bin/helm lint $(find ${DIR}/../deploy -type d -maxdepth 1 -mindepth 1)
