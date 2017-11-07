### Jenkins (deprecated)

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

gcloud dns --project=beta-180508 record-sets transaction execute --zone=landg


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

