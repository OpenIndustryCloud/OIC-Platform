#!/bin/bash

MYNAME="$(readlink -f $0)"
MYDIR="$(dirname ${MYNAME})"

/server &

find /userfunc -maxdepth 1 -name "*.go" -exec go build -buildmode=plugin -o function.so $filename {} \; -exec mv function.so /userfunc/user \;

sleep 1

# First we need to perform the Specialize Option
curl -sL -XPOST http://localhost:8888/specialize && {
	echo "successfully specialized code"
} || { 
	echo "Failed to specialize. Check your code!!"
	exit 1
	}

newman run /userfunc/ci/collection.json

rm -f /userfunc/user && exit 0
