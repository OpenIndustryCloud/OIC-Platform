#!/bin/bash

set -eux

MYNAME="$(readlink -f $0)"
MYDIR="$(dirname ${MYNAME})"
CURRENT_DIR="$(pwd)"

python3 /app/server.py &

[ -d /userfunc ] || { 
	echo "${CURRENT_DIR}"
	ls -l
	ln -sf "${CURRENT_DIR}/src" /userfunc
}

find /userfunc -maxdepth 1 -name "*.py" -exec ln -sf {} /userfunc/user \;

sleep 2

# First we need to perform the Specialize Option
curl -sL -XPOST http://localhost:8888/specialize && {
	echo "successfully specialized code"
} || { 
	echo "Failed to specialize. Check your code!!"
	exit 1
	}

newman run /userfunc/ci/collection.json

rm -f /userfunc/user /userfunc/__* 
