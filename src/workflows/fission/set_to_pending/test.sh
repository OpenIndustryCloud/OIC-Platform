#!/bin/bash

ENVIRONMENT="python"
MYNAME="$(readlink -f "$0")"
MYDIR=$(dirname "${MYNAME}" | rev | cut -f1 -d/ | rev)

find . -name "${MYDIR}.*" -exec cp {} user \;

docker run --rm \
	-p 8888:8888 \
	-v $PWD:/userfunc \
	--name ${ENVIRONMENT} \
	fission/${ENVIRONMENT}-env &

# sleeping to let the container start
sleep 3

curl -XPOST http://localhost:8888/specialize

echo "You can now run test your function by running a local curl such as"
echo
echo "$ curl -d '{\"id\":\"1234\",\"status\":\"new\"}'"
echo "   -H 'Content-Type: application/json'"
echo "   -X POST http://localhost:8888"
echo 
echo "When you are done you can clean up with"
echo "$ ./cleanup.sh"