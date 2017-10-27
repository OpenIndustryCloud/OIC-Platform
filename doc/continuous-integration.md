# Continuous Integration

The definitive solution for this element is not yet decided and we are experimenting with both Jenkins and GitLab CI. Below are methods to deploy both. 

## Concourse

[Concourse](https://kubeapps.com/charts/stable/concourse) can be deployed using the stable Helm repository. It relies on PostGreSQL to store configuration data. 

First we need a CNAME that maps to our round robin DNS: 

<pre><code>
[ -f transaction.yaml ] && rm -f transaction.yaml
gcloud dns record-sets transaction start --zone ${ZONE}
gcloud dns record-sets transaction add \
	--zone ${ZONE} \
	--name concourse.${DOMAIN}. \
	--ttl 600 \
	--type CNAME ingress.${DOMAIN}.
gcloud dns record-sets transaction execute --zone ${ZONE}
</code></pre>

Now we can deploy Concourse with a custom values file that includes a TLS protected ingress. Rotation and management of certs will be done via Kube-lego

<pre><code>
sed s#DOMAIN#${DOMAIN}#g etc/concourse-values.yaml > /tmp/concourse-values.yaml 

helm install --name concourse \
	--namespace concourse \
	--values /tmp/concourse-values.yaml \
	stable/concourse
</code></pre>

Note that we could have used a LoadBalancer. However LB are construct that map deep into the cloud primitives and with our global reach target we prefer the Ingress object. We can now connect on our URL https://concourse.${DOMAIN} and enjoy our newly deployed CI solution. 

At this point you need to download the CLI tools for Concourse using the landing page. More about this [in the official documentation](https://github.com/concourse/fly)

Note that the CA from KubeLego will not be trusted with the demo account. To download the CA from the website and let Concourse trust it, do: 

<pre><code>
openssl s_client -servername concourse.${DOMAIN} \
   -connect concourse.${DOMAIN}:443 \
   </dev/null | \
   sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
   > ca-concourse.pem
</code></pre>

Then login with 

<pre><code>
fly -t ${PROJECT_NAME} login -c https://concourse.${DOMAIN} --ca-cert ca-concourse.pem
</code></pre>

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

# Artifact Storage
## Sonatype Nexus 




<pre><code>

</code></pre>


