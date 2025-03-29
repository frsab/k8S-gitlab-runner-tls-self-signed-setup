# Kubernetes GitLab Runner Workshop
This repository provides a hands-on workshop to set up and configure GitLab with TLS certificates and GitLab Runners in a Kubernetes environment. The setup includes the creation of Kubernetes secrets for TLS certificates, deploying GitLab using Helm, and configuring GitLab Runners to run CI/CD jobs.

## Table of Contents
Prerequisites

Overview

Setup Instructions

* Step 1: Create TLS Secret

* Step 2: Set Up GitLab Deployment

* Step 3: Configure GitLab Runner via Helm

* Step 4: Mount Custom Hosts

Troubleshooting

Additional Information

Prerequisites
A working Kubernetes cluster (local or cloud)

Helm 3.x installed

kubectl installed

GitLab TLS certificate (gitlab.crt)

Overview
This project demonstrates the process of setting up GitLab in Kubernetes, integrating self-signed TLS certificates for secure communication, and configuring GitLab Runner with Helm for CI/CD automation. The project includes the following key steps:

TLS Secret Creation: Secure GitLab communication by creating a Kubernetes secret for the GitLab TLS certificate.

GitLab Deployment: Use Helm to deploy GitLab in the Kubernetes environment.

GitLab Runner Configuration: Install and configure GitLab Runner to execute CI/CD jobs.

Hosts Management: Mount a custom /etc/hosts configuration to allow the pods to resolve GitLab services locally.

Setup Instructions
Step 1: Create TLS Secret
To securely store the GitLab certificate (gitlab.crt), we'll create a Kubernetes secret. The secret will be used by pods to securely communicate with the GitLab instance.

Run the following command to create the secret:

bash
Copier
Modifier
sudo kubectl create secret generic gitlab-tls --from-file=gitlab.crt=/etc/gitlab/ssl/gitlab.crt -n ns-gr
This will create a secret named gitlab-tls in the ns-gr namespace.

Step 2: Set Up GitLab Deployment
You can deploy GitLab using Helm. If you haven't already set up Helm, follow the installation instructions here.

Once Helm is installed, add the GitLab Helm repository:

bash
Copier
Modifier
helm repo add gitlab https://charts.gitlab.io
helm repo update
Install GitLab using the Helm chart:

bash
Copier
Modifier
helm install gitlab gitlab/gitlab -n ns-gr --create-namespace
This will deploy GitLab in the ns-gr namespace. Make sure to configure the necessary values to match your environment (e.g., domain, persistence).

Step 3: Configure GitLab Runner via Helm
To run GitLab CI/CD jobs in your Kubernetes cluster, we will set up GitLab Runner using Helm.

First, add the GitLab Runner Helm repository:

bash
Copier
Modifier
helm repo add gitlab https://charts.gitlab.io
helm repo update
Install GitLab Runner using Helm:

bash
Copier
Modifier
helm install gitlab-runner gitlab/gitlab-runner -n ns-gr
You can configure the runner by updating the values.yaml or overriding settings directly in the Helm command. For example, you can specify the GitLab URL, runner tokens, and more.

Step 4: Mount Custom Hosts
In order for the GitLab pods and runners to resolve gitlab.optiplex3060 or other internal services, you need to add custom entries to the /etc/hosts file inside the pods. This can be done via a ConfigMap or using hostAliases in the pod specification.

Create a ConfigMap with custom hosts:
```yaml
Copier
Modifier
apiVersion: v1
kind: ConfigMap
metadata:
  name: custom-hosts
  namespace: ns-gr
data:
  hosts: |
    192.168.1.76 gitlab.optiplex3060
```

Mount the custom hosts file in your pod spec:

```yaml
Copier
Modifier
volumeMounts:
  - name: gitlab-tls-volume
    mountPath: /etc/gitlab-tls
    readOnly: true
  - name: custom-hosts
    mountPath: /etc/hosts
    subPath: hosts
```

This will mount the hosts file with the specified entries and make it available to the containers inside the pods.

Troubleshooting
Common Issues
TLS Errors: If you encounter issues with TLS verification, ensure that the correct certificate is mounted inside the pod and that the curl or other tools are correctly pointing to the certificate.

DNS Resolution: If gitlab.optiplex3060 is not resolving, verify that the hosts entries are correctly set up or use hostAliases in the pod spec.

GitLab Runner Not Registering: Ensure that the GitLab Runner is properly configured with a valid GitLab URL and registration token.

Additional Information
GitLab Helm Chart Documentation: https://docs.gitlab.com/charts/

GitLab Runner Helm Chart Documentation: https://docs.gitlab.com/runner/install/kubernetes.html

