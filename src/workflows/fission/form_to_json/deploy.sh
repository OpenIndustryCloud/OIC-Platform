#!/usr/bin/env bash

ENVIRONMENT="node"
FUNCTION="form-to-json"

fission env get --name ${ENVIRONMENT} || fission env create --name ${ENVIRONMENT} --image fission/${ENVIRONMENT}-env:0.3.0

fission fn create --name ${FUNCTION} --env ${ENVIRONMENT} --code ./form_to_json.js

echo "this function will convert a JSON POST data to new JSON with a random risk added to it"
echo 
echo "To use it do:"
echo "  $ fission route create --method POST --url /${FUNCTION} --function ${FUNCTION}" 
echo "  $ curl -d 'param1=value1&param2=value2'  \\"
echo "      -H 'Content-Type: application/x-www-form-urlencoded' \\"
echo "      -X POST http://$FISSION_ROUTER/${FUNCTION}"