#!/bin/sh

set -e -u -x

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

export GOPATH=$(pwd)/gopath:"${DIR}/../"

cd "${DIR}/.."

go test ./...
