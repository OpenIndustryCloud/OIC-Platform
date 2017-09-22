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
gcloud config set compute/region europe-west2
gcloud config set compute/zone europe-west2-a
</code></pre>

Now let us do the important part: setup a cluster

<pre><code>
gcloud container clusters create my-first-cluster \
  --cluster-version 1.7.5 \
  --no-enable-cloud-monitoring \
  --no-enable-cloud-logging \
  --num-nodes 3 \
  --machine-type n1-standard-4 
</code></pre>

Now we just have to download our cluster credentials

<pre><code>
gcloud container clusters get-credentials my-first-cluster
</code></pre>

and check we are OK with 

<pre><code>
kubectl cluster-info

kubectl get nodes --show-labels
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

## Continuous Integration

The definitive solution for this element is not yet decided and we are experimenting with both Jenkins and GitLab CI. Below are methods to deploy both. 

### Jenkins

Jenkins can be deployed using the stable Helm repository. It is to be noted that the configuration of Jenkins is stored as files in the home folder of the jenkins user. As such, it is very easy to save and transport configuration between deployments and environments. 

It is also recommended to isolate a separate volume dedicated to Jenkins instead of using a storage class, which will allow us to leverage cloud tools to perform backups and changes. Google edited a nice repository to explain that part [here](https://github.com/googlecloudplatform/continuous-deployment-on-kubernetes)

### GitLab (deprecated)

Installing GitLab on K8s is officially supported and available [here](https://docs.gitlab.com/ee/install/kubernetes/gitlab_omnibus.html). Note that a more advanced version is currently WIP and planned for Q2 2018. 

First add the GitLab Chart Repository

<pre><code>
helm repo add gitlab https://charts.gitlab.io
</code></pre>

Now create an IP address for the load balancer: 

<pre><code>
gcloud compute addresses create gitlab \
	--description=IP\ Address\ for\ the\ GitLab\ Load\ Balancer \
	--region europe-west2

GITLAB_IP=$(gcloud compute addresses list --format json --filter name=gitlab | jq --raw-output '.[].address')
</code></pre>

Now create an entry gitlab.${ZONE}.${DOMAIN} with: 

<pre><code>
gcloud dns record-sets transaction start --zone=${ZONE}
gcloud dns record-sets transaction add ${GITLAB_IP} \
	--name=gitlab.${ZONE}.${DOMAIN}. 
	--ttl=300 \
	--type=A \
	--zone=${ZONE}
for host in prometheus mattermost registry; do
	gcloud dns record-sets transaction add gitlab.${ZONE}.${DOMAIN}. \
		--name=prometheus.${ZONE}.${DOMAIN}. \
		--ttl=300 \
		--type=CNAME \
		--zone=${ZONE}
done

gcloud dns --project=landg-179815 record-sets transaction execute --zone=landg


gcloud dns record-sets transaction execute --zone=${ZONE}
</code></pre>

Now edit the file **etc/gitlab-values.yaml** to add your DNS zone in baseDomain, your email address and other required details. 

**IMPORTANT NOTE**: At the time of this writing (20170922) there is a [bug in the Gitlab chart](https://gitlab.com/charts/charts.gitlab.io/issues/71) on GKE so we have a temporary fork in our own repo. 
There is also a [secondary bug](https://gitlab.com/gitlab-org/gitlab-ce/issues/35822) that prevents deploying

Finally deploy with: 

<pre><code>
helm install --name gitlab \
	--values etc/gitlab-values.yaml \
	./src/charts/gitlab-omnibus
</code></pre>

## ElasticSearch

To deploy ElasticSearch we use a custom Helm Chart inspired by https://github.com/clockworksoul/helm-elasticsearch





<pre><code>

</code></pre>






