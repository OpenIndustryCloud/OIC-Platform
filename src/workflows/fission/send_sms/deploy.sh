#!/usr/bin/env bash

ENVIRONMENT="python-twilio"
FUNCTION="send-sms"
CODE="send_sms.py"

fission env get --name ${ENVIRONMENT} || fission env create --name ${ENVIRONMENT} --image gcr.io/landg-179815/python-env:latest

fission fn create --name ${FUNCTION} --env ${ENVIRONMENT}-twilio --code ./${CODE}

echo "this function accept or deny a POST depending on the value of the risk factor"
echo 
echo "To use it do:"
echo "  $ fission route create --method POST --url /${FUNCTION} --function ${FUNCTION}" 
echo "  $ curl -d '{\"id\":\"1234\", \"status\":\"denied\", \"risk\": 50}' \\"
echo "      -H 'Content-Type: application/json' \\"
echo "      -X POST http://$FISSION_ROUTER/${FUNCTION}"
