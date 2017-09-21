# Legal and General Platform
## Introduction

Welcome to the Open Industry Cloud platform. The goal of this project is to develop and open source a standard Open Source application platform for the Insurance industry. For InsurTech startups, it is a nean to accelerate development by focusing on their wits and added value. For historical players, it aims at speeding up product development and bring Google speed. 

## Components

Similar to classic PaaS solutions, this solution will provide

* Code Hosting
* Continuous Integration
* Continuous Deployment Pipelining
* Application Packaging
* Docker Registry
* Orchestration (Kubernetes)
* Logging
* Monitoring
* Service Mesh
* Service Catalog
  * File Storage 
  * Columnar DataStore 
  * SQL DataStore 
  * JSON DataStore 
  * Other Applications (Fraud Analysis, Anomaly Detection...)
* Identity Management
* Billing 

Because it is focused on the insurance business, specific focus is given to 

* Security 
* Data Management

## Quick Start

This platform can be deployed on GKE to start experimenting. Follow our [Quick Start](/docs/quickstart.md) for more information. 

If you do not have a Google Cloud account then you can use any distribution of Kubernetes of your liking and use the Helm Charts provided here. See [Deploying with Helm](/docs/deploying-with-helm.md)

## Architecture

The requirements for this project we fairly simple. Everything must be open source with an acceptable licence. In addition, individual components must have a commercial support entity available in order to move to production.

More information about the architecture [here](/docs/architecture.md)

## License

This project is under the [MIT License](https://opensource.org/licenses/MIT)

