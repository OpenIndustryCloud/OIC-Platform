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
	--name concourse.${ZONE}.${DOMAIN}. \
	--ttl 600 \
	--type CNAME ingress.${ZONE}.${DOMAIN}.
gcloud dns record-sets transaction execute --zone ${ZONE}
</code></pre>

Now we can deploy Concourse with a custom values file that includes a TLS protected ingress. Rotation and management of certs will be done via Kube-lego

<pre><code>
sed -e s#DOMAIN#${DOMAIN}#g \
	-e s#ZONE#${ZONE}#g \
	etc/concourse-values.yaml > /tmp/concourse-values.yaml 

helm install --name concourse \
	--namespace concourse \
	--values /tmp/concourse-values.yaml \
	stable/concourse
</code></pre>

Note that we could have used a LoadBalancer. However LB are construct that map deep into the cloud primitives and with our global reach target we prefer the Ingress object. We can now connect on our URL https://concourse.${DOMAIN} and enjoy our newly deployed CI solution. 

At this point you need to download the CLI tools for Concourse using the landing page. More about this [in the official documentation](https://github.com/concourse/fly)

Note that the CA from KubeLego will not be trusted with the demo account. To download the CA from the website and let Concourse trust it, do: 

<pre><code>
openssl s_client -servername concourse.${ZONE}.${DOMAIN} \
   -connect concourse.${ZONE}.${DOMAIN}:443 \
   </dev/null | \
   sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
   > ca-concourse.pem
</code></pre>

Then login with 

<pre><code>
fly -t ${PROJECT_NAME} login -c https://concourse.${DOMAIN} --ca-cert ca-concourse.pem
</code></pre>

At this stage we have Concourse setup and can move forward to the Nexus, which we will use to store our build artifacts

# Artifact Storage
## Sonatype Nexus 

TBD


<pre><code>

</code></pre>


