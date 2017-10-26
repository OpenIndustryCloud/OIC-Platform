#!/bin/sh

MYNAME="$(readlink -f $0)"
MYDIR="$(dirname ${MYNAME})"

find /userfunc -name "*.py" -exec cp {} /userfunc/user \;

node $DIR/../server.js --port 8888 &

# Should replace this by a proper test
sleep 3

# First we need to perform the Specialize Option
curl -sL -XPOST http://localhost:8888/specialize && {
	echo "successfully specialized code"
} || { 
	echo "Failed to specialize. Check your code!!"
	exit 1
	}

newman run /userfunc/ci/collection.json

rm -f /userfunc/user && exit 0
