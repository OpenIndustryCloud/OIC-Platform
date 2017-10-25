#!/usr/bin/env bash

ENVIRONMENT="python"
FUNCTION="make-decision"
CODE="make_decision.py"

fission env get --name ${ENVIRONMENT} || fission env create --name ${ENVIRONMENT} --image fission/${ENVIRONMENT}-env:0.3.0

fission fn create --name ${FUNCTION} --env ${ENVIRONMENT} --code ./${CODE}

echo "this function accept or deny a POST depending on the value of the risk factor"
echo 
echo "To use it do:"
echo "  $ fission route create --method POST --url /${FUNCTION} --function ${FUNCTION}" 
echo "  $ curl -d '{\"id\":\"1234\", \"status\":\"pending\", \"risk\": 50}' \\"
echo "      -H 'Content-Type: application/json' \\"
echo "      -X POST http://$FISSION_ROUTER/${FUNCTION}"