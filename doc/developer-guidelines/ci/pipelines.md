At this point we need to configure our resources and pipelines, which we can do via: 

<pre><code>
# Configure your Slack to welcome message via [this link](https://my.slack.com/services/new/incoming-webhook/) then 
export SLACK_URL=https://hooks.slack.com/services/hook/serviceID/UUID

export CLIENT_CERT=$(gcloud container clusters describe ${K8S_CLUSTER_NAME} --format json | jq --raw-output '.masterAuth.clientCertificate' | base64 -w0 )

export CLIENT_KEY=$(gcloud container clusters describe ${K8S_CLUSTER_NAME} --format json | jq --raw-output '.masterAuth.clientKey' | base64 -w0 )

export CLIENT_CA=$(gcloud container clusters describe ${K8S_CLUSTER_NAME} --format json | jq --raw-output '.masterAuth.clusterCaCertificate' | base64 -w0 )

sed -e s#ZONE#${ZONE}#g \
	-e s#DOMAIN#${DOMAIN}#g \
	-e s#CLUSTER_CA#${CLUSTER_CA}#g \
	-e s#CLIENT_KEY#${CLIENT_KEY}#g \
	-e s#CLIENT_CERT#${CLIENT_CERT}#g \
	-e s#PROJECT_NAME#${PROJECT_NAME}#g \	
	-e s#BUCKET_NAME#${BUCKET_NAME}#g \	
	-e s#SLACK_URL#${SLACK_URL}#g \	
	etc/concourse-pipelines.yaml \
	> /tmp/helm-resource.yaml
</code></pre>
