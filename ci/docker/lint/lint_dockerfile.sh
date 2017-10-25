#!/bin/bash

set -e -u -x

find "${SEARCH_PATH:-'.'}" -maxdepth 1 -name "Dockerfile" \
	-exec echo "Starting linting " {} \; \
	-exec dockerfile_lint -p -f {} \;

echo "Linted all files with success"
