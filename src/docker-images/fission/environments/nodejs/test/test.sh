#!/bin/sh

MYNAME="$(readlink -f $0)"
MYDIR="$(dirname ${MYNAME})"

[ -d /userfunc ] || { 
	echo "We start in ${CURRENT_DIR}"
	ln -sf "${CURRENT_DIR}/src" /userfunc
}

find /userfunc -maxdepth 1 -name "*.js" -exec ln -sf {} /userfunc/user \;

node /usr/src/app/server.js --port 8888 &

# Should replace this by a proper test
sleep 2

# First we need to perform the Specialize Option
curl -sL -XPOST http://localhost:8888/specialize && {
	echo "successfully specialized code"
} || { 
	echo "Failed to specialize. Check your code!!"
	exit 1
	}

newman run /userfunc/ci/collection.json

rm -f /userfunc/user
