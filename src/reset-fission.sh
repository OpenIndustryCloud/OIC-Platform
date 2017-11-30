#!/bin/bash

set -eux

[ "x${ZONE}" = "x" ] && { 
	echo "please set ENV variable ZONE and DOMAIN"
	exit 1
}

[ "x${DOMAIN}" = "x" ] && { 
	echo "please set ENV variable ZONE and DOMAIN"
	exit 1
}

helm delete --purge fission-workflows

helm delete --purge fission-all

kubectl delete job -n fission fission-all-fission-all

sleep 60

helm install --namespace fission \
	--name fission-all \
	fission-charts/fission-all \
	--values ~/Documents/src/projects/landg/oic/etc/fission-values.yaml

sleep 30

helm install --namespace fission \
	--name fission-workflows \
	fission-charts/fission-workflows \
	--values ~/Documents/src/projects/landg/oic/etc/fission-wf-values.yaml

sleep 30

FISSION_ROUTER=$(kubectl --namespace fission get svc router -o=jsonpath='{..ip}')

PREVIOUS_ADDRESS="$(nslookup fission.${ZONE}.${DOMAIN} | tail -n3 | grep Address | cut -f2 -d:)"

echo "please update the DNS in a few seconds"
gcloud dns record-sets transaction start --zone=${ZONE}
gcloud dns record-sets transaction remove \
  --zone ${ZONE} \
  --name fission.${ZONE}.${DOMAIN}. \
  --ttl 300 \
  --type A \
  ${PREVIOUS_ADDRESS}

gcloud dns record-sets transaction add ${FISSION_ROUTER} \
  --name=fission.${ZONE}.${DOMAIN}. \
  --ttl=300 \
  --type=A \
  --zone=${ZONE}
gcloud dns record-sets transaction execute --zone=${ZONE}


export FISSION_ROUTER=$(kubectl --namespace fission get svc router -o=jsonpath='{..ip}')

export FISSION_URL=http://$(kubectl --namespace fission get svc controller -o=jsonpath='{..ip}')

