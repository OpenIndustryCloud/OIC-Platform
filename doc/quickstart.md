This document aims at providing a fast track to get the platform up & running in less than an hour on GCP. 

# Getting ready

First of all you need an account on GCP with billing enabled. Activate the following API: 

* [Service Management API](https://console.cloud.google.com/apis/api/servicemanagement.googleapis.com/overview)
* [Google Cloud Resource Manager API](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/overview)
* [Google Container Registry API](https://console.cloud.google.com/apis/api/containerregistry.googleapis.com/overview)

Then make sure that you install

* The [Google Cloud SDK](https://cloud.google.com/sdk/downloads). Do not forget to add kubectl to the list of components. 
* [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md)
* [Calico Client](https://docs.projectcalico.org/v2.4/usage/calicoctl/install-and-configuration)
* [etcd client](https://github.com/coreos/etcd/releases)

You will also need a Cloud DNS zone for some of the setup. Info about this process is documented [here](https://cloud.google.com/dns/migrating). Once you have a DNS zone pointed to Google Cloud DNS, create it with


<pre><code>
export PROJECT_NAME=my-project 
export ZONE=myproject
export DOMAIN=example.com 

gcloud dns managed-zones create ${ZONE} \
	--dns-name=${ZONE}.${DOMAIN}.
</code></pre>

# Installing a GKE cluster via the command line

Some guidelines to deploy a cluster are documented on GCP [here](https://cloud.google.com/container-engine/docs/quickstart)

As always start with updating the components of your installation

<pre><code>
gcloud components update
</code></pre>

Now let us focus on just one region for our cluster

<pre><code>
export REGION=europe-west2
export GCP_ZONE=a

gcloud config set compute/region ${REGION}
gcloud config set compute/zone ${REGION}-${GCP_ZONE}
</code></pre>

Now let us do the important part: setup a cluster

<pre><code>
export K8S_CLUSTER_NAME=my-first-clusteer
gcloud container clusters create ${K8S_CLUSTER_NAME} \
  --cluster-version 1.7.8 \
  --no-enable-cloud-monitoring \
  --no-enable-cloud-logging \
  --num-nodes 3 \
  --machine-type n1-standard-4 \
  --image-type UBUNTU 
</code></pre>

Now we just have to download our cluster credentials

<pre><code>
gcloud container clusters get-credentials ${K8S_CLUSTER_NAME}
</code></pre>

and check we are OK with 

<pre><code>
kubectl cluster-info

kubectl get nodes --show-labels
</code></pre>

For future usage and integration, let us create a gcloud DNS entry for our K8s cluster API: 

<pre><code>
K8S_API_IP=$(gcloud container clusters describe ${K8S_CLUSTER_NAME} --format json | jq --raw-output '.endpoint')

gcloud dns record-sets transaction start --zone=${ZONE}
gcloud dns record-sets transaction add ${K8S_API_IP} \
  --name=k8s.${ZONE}.${DOMAIN}. 
  --ttl=300 \
  --type=A \
  --zone=${ZONE}
gcloud dns record-sets transaction execute --zone=${ZONE}
</code></pre>

# Installing addons

Everything we do will run in Kubernetes and will mostly be deployed via Helm. 

First of all add the Helm incubator repo, update content and initialize the cluster 

<pre><code>
helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
helm repo update
helm init 
</code></pre>

Now you are ready to deploy the rest of the add-ons. 

## Create a Chart Repository

Follow this [document](https://github.com/kubernetes/helm/blob/master/docs/chart_repository.md) to setup a GS bucket and make sure we can store charts in it. Using the CLI it gives: 

<pre><code>
BUCKET_NAME=my-chart-bucket

gsutil mb -c regional -l ${REGION} gs://${BUCKET_NAME}
gsutil acl ch -R -u AllUsers:R gs://${BUCKET_NAME}

helm repo add project-charts https://${BUCKET_NAME}.storage.googleapis.com
helm repo update
</code></pre>


Then the process to sync charts is documented [here](https://github.com/kubernetes/helm/blob/master/docs/chart_repository_sync_example.md) and will be integrated in the CI CD pipeline later on. 

## Ingress Deployment

Using ingress will give us better application portability than using the default LoadBalancer by most cloud providers, especially when operating on Bare Metal or VMWare environment. 

There are 2 ways to look at this. Initially, nginx can be seen as the safest option since it is widely used in commercial offerings such as GKE or CDK. This is fine for starters, and we will add Kube Lego to manage our TLS certs on top of it. 

On the longer term, with Istio being our target for service mesh, we will add an Istio Ingress to the mix. 

### Deploying the nginx ingress

Google has put a lot of efforts into stabilizing a proper ingress for GKE and we see no reason to reinvent the wheel here. We will use the stable chart for it, with a lightly customized configuration: 

First let us create an IP address for the load balancer: 

<pre><code>
gcloud compute addresses create nginx-ingress \
  --description=IP\ Address\ for\ the\ Ingress\ Load\ Balancer \
  --region ${REGION}

NGINX_INGRESS_IP=$(gcloud compute addresses list --format json --filter name=nginx-ingress | jq --raw-output '.[].address')
</code></pre>

Now create an entry ingress.${ZONE}.${DOMAIN} with: 

<pre><code>
gcloud dns record-sets transaction start --zone=${ZONE}
gcloud dns record-sets transaction add ${NGINX_INGRESS_IP} \
  --name=ingress.${ZONE}.${DOMAIN}. 
  --ttl=300 \
  --type=A \
  --zone=${ZONE}
gcloud dns record-sets transaction execute --zone=${ZONE}
</code></pre>

Now let us customize our nginx-values.yaml file and install the chart with

<pre><code>
sed s#NGINX_INGRESS_IP#${NGINX_INGRESS_IP}#g etc/nginx-values.yaml > /tmp/nginx-values.yaml 

helm install --name nginx \
	--namespace kube-public \
	--values /tmp/nginx-values.yaml \
	stable/nginx-ingresscxcxz
</code></pre>

### Secure nginx ingress with Let's Encrypt

First of all we create a round robin DNS on our hosts with 

<pre><code>
[ -f transaction.yaml ] && rm -f transaction.yaml
gcloud dns record-sets transaction start --zone ${ZONE}
gcloud dns record-sets transaction add \
	--zone ${ZONE} \
	--name ingress.${DOMAIN}. \
	--ttl 600 \
	--type A $(kubectl get nodes \
		-o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}')
gcloud dns record-sets transaction execute --zone ${ZONE}
</code></pre>

Now we deploy Kube Lego with 

<pre><code>
helm install --name kube-lego \
	--namespace kube-system \
	--values etc/kubelego-values.yaml \
	stable/kube-lego
</code></pre>

From now on we can create TLS ingress and let Kube Lego automatically create certs and manage them over time. 

## Administrative Tools
### Monitoring 
#### Prometheus

[Prometheus](https://kubeapps.com/charts/stable/prometheus) can be deployed using the stable Helm repository. 

First we need a few CNAME that map to our round robin DNS: 

<pre><code>
[ -f transaction.yaml ] && rm -f transaction.yaml
gcloud dns record-sets transaction start --zone ${ZONE}

for domain in alertmanager prometheus pushgateway 
do 
	gcloud dns record-sets transaction add \
		--zone ${ZONE} \
		--name ${domain}.${DOMAIN}. \
		--ttl 600 \
		--type CNAME ingress.${DOMAIN}.
done 

gcloud dns record-sets transaction execute --zone ${ZONE}
</code></pre>

Now we can deploy Prometheus with a custom values file that includes a TLS protected ingress. Rotation and management of certs will be done via Kube-lego

<pre><code>
sed s#DOMAIN#${DOMAIN}#g etc/promethus-values.yaml > /tmp/promethus-values.yaml

helm install --name prometheus \
	--namespace prometheus \
	--values /tmp/prometheus-values.yaml \
	stable/prometheus
</code></pre>


#### Sysdig

Create an account on [Sysdig Cloud](https://sysdig.com/) and follow the instruction to deploy the Sysdig Agent on all nodes. 

**Important Note**: Sysdig does not support the Container Optimized System image that GKE uses by default. You absolutely need to use the ubuntu setup. 

### Logging
#### ElasticSearch

Currently we use logz.io to get an ELKaaS. You can get a free account if your consumption is less than 1GB/day with a retention of 4 days. Once you have it, export the token with 

<pre><code>
export LOGZIO_TOKEN=YourToken
</code></pre>

Next: To deploy ElasticSearch we use a custom Helm Chart inspired by https://github.com/clockworksoul/helm-elasticsearch

#### Fluent Bit

To install Fluent with support for logz.io we opened a PR on the official image [here](https://github.com/fluent/fluentd-kubernetes-daemonset/pull/55)

We then adapted the provided manifest while we work on a chart for it. Deploy with 

<pre><code>
sed s#ThisIsALongToken#${LOGZIO_TOKEN}#g etc/fluentd-manifest.yaml > /tmp/fluentd-manifest.yaml

kubectl create -f /tmp/fluentd-manifest.yaml
</code></pre>





