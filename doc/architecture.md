This document outlines the various components of the platform as well as their interactions and deployment methods. 

# Code Hosting
## Public Applications

GitHub.com is the preferred solution to store code for public applications. 

## Private Applications

Any private git repo, hosted or on premises is OK for these. 

# Continuous Integration 


We use [Jenkins](https://jenkins.io/) for all CI processes.

In addition, we recommend using [Draft](https://github.com/Azure/draft) for developers. 

# Packaging / Continuous Deployment

We use a combination of Jenkins and [Helm](https://github.com/kubernetes/helm) to package applications and deploy them to K8s.

# Docker Registry

We use [Nexus](https://www.sonatype.com/nexus-repository-oss) as the artifact repository, including Docker Images. 

# Orchestration (Kubernetes)

We use [Kubernetes](https://kubernetes.io) as the core of the solution to run and manage all applications, including all databases made available as a service. 

Note that K8s must be installed with RBAC support to get the full extend of the platform, and that Network Policies are also strongly recommended meaning that the networking options exclude Flannel. [Calico](https://www.projectcalico.org/) is the recommended solution but any other CNI with policies support should do. 

# Logging

We rely on [Fluent Bit](http://fluentbit.io/) to collect logs and ship them to ElasticSearch. We use Kibana for visualization. 

# Monitoring

We use 2 solutions for monitoring. 

* [Prometheus](https://prometheus.io/) as it allows collecting application metrics and mix them with technical metrics. 
* [Sysdig](https://sysdig.com/) for more advanced technical / profiling monitoring 

# Service Mesh

We use [Istio](https://istio.io/) to provide service mesh and end-to-end encryption. 

# Service Catalog
## File Storage 

File Storage will be provided using [Minio](https://www.minio.io/), an S3 compliant solution. 

## Columnar DataStore 

Each platform will host a Cassandra instance in development mode. Whenever moving to production, DataStax Enterprise is the preferred option. 

## SQL DataStore 

In order to provide web scale SQL stores we use CockroachDB as the default SQL backend. CockroachDB provides a postgresql compliant interface.  

## JSON DataStore 

To store JSON documents, applications can rely on [CouchDB](Apache CouchDB).  

## Other Applications (Fraud Analysis, Anomaly Detection...)

These applications are future additions to the platform designed by community members that can be applied transversally to any of the "over the top" applications. For example, an anomaly detection solution could be queried by a service through the service broker pipeline. 

# Identity Management

Identity management at the platform level will be managed via [KeyCloak](http://www.keycloak.org/). 

# Billing 

TBD.

# Other Components
## Secrets Storage

While K8s provides encrypted storage since 1.7, we feel that an external secret storage system makes sense, at the very minimum to host certificates and other infrastructure level items. [Vault](https://www.vaultproject.io/) is the solution for this. 
