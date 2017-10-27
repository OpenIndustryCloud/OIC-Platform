#!/bin/bash

set -eux

MYNAME="$(readlink -f $0)"
MYDIR="$(dirname ${MYNAME})"
CURRENT_DIR="$(pwd)"

[ -d /userfunc ] || { 
	cp -r "${CURRENT_DIR}/src/${FUNCTION_PATH}" /userfunc
	ls -lR /userfunc
}

find /userfunc -maxdepth 1 -name "*.py" -exec ln -sf "{}" /userfunc/user \;

python3 /app/server.py &

sleep 2

# First we need to perform the Specialize Option
curl -sL -XPOST http://localhost:8888/specialize && {
	echo "successfully specialized code"
} || { 
	echo "Failed to specialize. Check your code!!"
	exit 1
	}

newman run /userfunc/ci/collection.json

rm -rf /userfunc/user /userfunc/__pycache__
