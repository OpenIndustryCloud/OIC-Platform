#!/bin/bash

set -eux

MYNAME="$(readlink -f $0)"
MYDIR="$(dirname ${MYNAME})"

/server &

[ -d /userfunc ] || { 
	echo "We start in ${CURRENT_DIR}"
	ln -sf "${CURRENT_DIR}/src/${FUNCTION_PATH}" /userfunc
}

find /userfunc -maxdepth 1 -name "*.bin" -exec ln -sf {} /userfunc/user \;

sleep 1

# First we need to perform the Specialize Option
curl -sL -XPOST http://localhost:8888/specialize && {
	echo "successfully specialized code"
} || { 
	echo "Failed to specialize. Check your code!!"
	exit 1
	}

newman run /userfunc/ci/collection.json

rm -f /userfunc/user
