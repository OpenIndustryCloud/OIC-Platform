#!/bin/bash

ENVIRONMENT="node"
MYNAME="$(readlink -f "$0")"
MYDIR=$(dirname "${MYNAME}" | rev | cut -f1 -d/ | rev)

find . -maxdepth 1 -name "*.js" -exec cp {} user \;

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
echo "$ curl -d 'param1=value1&param2=value2' \\"
echo "   -H 'Content-Type: application/x-www-form-urlencoded' \\"
echo "   -X POST http://localhost:8888"
echo 
echo "When you are done you can clean up with"
echo "$ ./cleanup.sh"

