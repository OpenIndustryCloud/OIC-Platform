#!/bin/bash

MYNAME="$(readlink -f $0)"
MYDIR="$(dirname ${MYNAME})"

/server &

find /userfunc -name "*.go" -exec cp {} /userfunc/user \;

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
