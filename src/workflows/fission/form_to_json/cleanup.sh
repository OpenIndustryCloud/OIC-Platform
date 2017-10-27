#!/bin/bash

ENVIRONMENT="node"
MYNAME="$(readlink -f "$0")"
MYDIR=$(dirname "${MYNAME}" | rev | cut -f1 -d/ | rev)

docker stop ${ENVIRONMENT}

sudo rm -rf node_modules user

echo "You cleaned up your test. Good to go! "
echo

