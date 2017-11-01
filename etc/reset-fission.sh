#!/bin/bash

helm delete --purge fission-workflows

helm delete --purge fission-all

kubectl delete job -n fission fission-all-fission-all

sleep 5

helm install --namespace fission \
	--name fission-all \
	fission-charts/fission-all \
	--values ~/Documents/src/projects/landg/oic/etc/fission-values.yaml

helm install --namespace fission \
	--name fission-workflows \
	fission-charts/fission-workflows \
	--values ~/Documents/src/projects/landg/oic/etc/fission-wf-values.yaml

echo "please update the DNS in a few seconds"
