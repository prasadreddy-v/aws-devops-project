# AWS EKS DevOps Platform – End-to-End Implementation

## Project Overview

This project demonstrates a complete production-grade DevOps platform implementation on AWS using modern cloud-native technologies.

The platform automates infrastructure provisioning, application deployment, monitoring, ingress management, DNS automation, SSL termination, and GitOps-based delivery.

### Objectives

* Infrastructure as Code (Terraform)
* Kubernetes Orchestration (Amazon EKS)
* Containerization (Docker)
* Container Registry (Amazon ECR)
* CI/CD Automation (GitHub Actions)
* Kubernetes Package Management (Helm)
* Monitoring & Observability (Prometheus + Grafana)
* Ingress Management (AWS Load Balancer Controller)
* DNS Automation (ExternalDNS)
* HTTPS Management (AWS ACM)
* GitOps Deployment (ArgoCD)
* Centralized Logging (Loki + Promtail)

---

# High-Level Architecture

```text
                         +-------------------+
                         |    Developer      |
                         +---------+---------+
                                   |
                                   v
                         +-------------------+
                         |      GitHub       |
                         +---------+---------+
                                   |
                                   v
                         +-------------------+
                         | GitHub Actions CI |
                         +---------+---------+
                                   |
              +--------------------+-------------------+
              |                                        |
              v                                        v
     +------------------+                  +------------------+
     |   Docker Build   |                  | Terraform Apply  |
     +------------------+                  +------------------+
              |                                        |
              v                                        v
     +------------------+                  +------------------+
     |    Amazon ECR    |                  | AWS Infrastructure|
     +------------------+                  +------------------+
                                                       |
                                                       v
                                             +------------------+
                                             | Amazon EKS       |
                                             +--------+---------+
                                                      |
                   +----------------------------------+--------------------------------+
                   |                                  |                                |
                   v                                  v                                v
           +---------------+                 +---------------+               +---------------+
           | Flask App     |                 | Prometheus    |               | ArgoCD        |
           | (Helm Chart)  |                 | Grafana       |               | GitOps        |
           +-------+-------+                 +---------------+               +---------------+
                   |
                   v
         +------------------------+
         | AWS ALB Controller     |
         +-----------+------------+
                     |
                     v
         +------------------------+
         | Application Load       |
         | Balancer (ALB)         |
         +-----------+------------+
                     |
                     v
         +------------------------+
         | ExternalDNS + Route53  |
         +-----------+------------+
                     |
                     v
         +------------------------+
         | ACM SSL Certificate    |
         +-----------+------------+
                     |
                     v
                End Users
```

---

# Repository Structure

```text
aws-devops-project
│
├── terraform
│   ├── vpc
│   ├── eks
│   ├── iam
│   └── environments
│
├── app
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
│
├── kubernetes
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── helm
│   └── flask-app
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates
│
├── argocd
├── alb-controller
├── external-dns
├── logging
│
└── .github
    └── workflows
```

---

# Phase 1 – AWS Account Preparation

## Required Tools

* AWS CLI
* Terraform
* kubectl
* Helm
* Docker
* Git
* eksctl

## Configure AWS

```bash
aws configure
```

Verify:

```bash
aws sts get-caller-identity
```

---

# Phase 2 – Infrastructure Provisioning using Terraform

## Resources Created

### Networking

* VPC
* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables

### Architecture

```text
VPC (10.0.0.0/16)

├── Public Subnet A
├── Public Subnet B
│
├── Private Subnet A
└── Private Subnet B
      │
      ▼
   EKS Nodes
```

## Deployment

```bash
terraform init

terraform plan

terraform apply
```

Outputs:

* cluster_name
* vpc_id
* public_subnet_ids
* private_subnet_ids

---

# Phase 3 – Amazon EKS Cluster Setup

## Verify Cluster

```bash
aws eks list-clusters --region ap-south-1
```

Check Status:

```bash
aws eks describe-cluster \
--name devops-eks \
--region ap-south-1 \
--query cluster.status
```

Expected:

```text
ACTIVE
```

Configure kubectl:

```bash
aws eks update-kubeconfig \
--name devops-eks \
--region ap-south-1
```

Verify:

```bash
kubectl get nodes
```

Expected:

```text
Ready
```

---

# Phase 4 – Application Containerization

## Build Docker Image

```bash
docker build -t flask-app .
```

Run Locally:

```bash
docker run -p 5000:5000 flask-app
```

---

# Phase 5 – Amazon ECR Setup

## Login

```bash
aws ecr get-login-password \
--region ap-south-1 | docker login \
--username AWS \
--password-stdin <ECR_URL>
```

## Push Image

```bash
docker tag flask-app <ECR_URL>/flask-app:latest

docker push <ECR_URL>/flask-app:latest
```

---

# Phase 6 – GitHub Actions CI/CD

## CI/CD Flow

```text
Developer Push
       │
       ▼
GitHub Repository
       │
       ▼
GitHub Actions
       │
 ┌─────┴─────┐
 │           │
 ▼           ▼
Build     Security Scan
 │
 ▼
Docker Image
 │
 ▼
Amazon ECR
 │
 ▼
EKS Deployment
```

## Pipeline Tasks

* Checkout Code
* Configure AWS Credentials
* Docker Build
* Push Image to ECR
* Deploy to EKS

---

# Phase 7 – Kubernetes Deployment

Resources:

* Deployment
* Service
* Ingress

Deployment:

```bash
kubectl apply -f deployment.yaml
```

Service:

```bash
kubectl apply -f service.yaml
```

Verification:

```bash
kubectl get pods
kubectl get svc
```

---

# Phase 8 – Helm Packaging

## Helm Chart Structure

```text
helm/flask-app

├── Chart.yaml
├── values.yaml
└── templates
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

Validate:

```bash
helm lint flask-app
```

Install:

```bash
helm install flask-app ./helm/flask-app
```

---

# Phase 9 – Monitoring Stack

## Components

* Prometheus
* Grafana
* AlertManager
* Node Exporter

Namespace:

```bash
monitoring
```

Install:

```bash
helm install monitoring \
prometheus-community/kube-prometheus-stack \
-n monitoring
```

Monitoring Flow:

```text
Kubernetes Cluster
        │
        ▼
   Prometheus
        │
        ▼
    Grafana
        │
        ▼
 Dashboards & Alerts
```

---

# Phase 10 – AWS Load Balancer Controller

Purpose:

Automatically provisions AWS Application Load Balancers from Kubernetes Ingress resources.

Components:

* IAM Policy
* IAM Role
* IRSA
* Controller Deployment

Verification:

```bash
kubectl get pods -n kube-system
```

Expected:

```text
aws-load-balancer-controller Running
```

---

# Phase 11 – Application Ingress

Ingress Annotations

```yaml
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
```

Flow:

```text
Ingress
   │
   ▼
AWS ALB
   │
   ▼
Application Pods
```

---

# Phase 12 – HTTPS using ACM

Certificate:

```text
AWS Certificate Manager (ACM)
```

Ingress Configuration:

```yaml
alb.ingress.kubernetes.io/certificate-arn
alb.ingress.kubernetes.io/listen-ports
alb.ingress.kubernetes.io/ssl-redirect
```

Flow:

```text
User
 │
 ▼
HTTPS
 │
 ▼
ACM Certificate
 │
 ▼
AWS ALB
 │
 ▼
Kubernetes Service
 │
 ▼
Pod
```

---

# Phase 13 – ExternalDNS

Purpose:

Automatically manages Route53 DNS records.

Flow:

```text
Kubernetes Ingress
        │
        ▼
    ExternalDNS
        │
        ▼
      Route53
        │
        ▼
app.mydevop.net
```

---

# Phase 14 – ArgoCD GitOps

Components:

* Application Controller
* API Server
* Repo Server
* Redis
* Dex

GitOps Flow:

```text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
ArgoCD
    │
    ▼
Kubernetes Cluster
    │
    ▼
Application Updated
```

Benefits:

* Continuous Reconciliation
* Drift Detection
* Automated Deployment
* Rollback Capability

---

# Phase 15 – Centralized Logging (Planned)

## Logging Architecture

```text
Flask Application
        │
        ▼
Container Stdout
        │
        ▼
Promtail
        │
        ▼
Loki
        │
        ▼
Grafana
```

Components:

* Loki
* Promtail
* Grafana

Verification:

```bash
kubectl get pods -n logging
```

---

# Current Project Status

| Component             | Status      |
| --------------------- | ----------- |
| Terraform             | Completed   |
| VPC                   | Completed   |
| EKS                   | Completed   |
| Docker                | Completed   |
| ECR                   | Completed   |
| GitHub Actions        | Completed   |
| Kubernetes Deployment | Completed   |
| Helm                  | Completed   |
| Prometheus            | Completed   |
| Grafana               | Completed   |
| AWS ALB Controller    | Completed   |
| ACM HTTPS             | Completed   |
| Route53               | Completed   |
| ExternalDNS           | Completed   |
| ArgoCD Installation   | Completed   |
| GitOps Sync           | In Progress |
| Loki Logging          | Planned     |

---

# Final Production Architecture

```text
GitHub
   │
   ▼
GitHub Actions
   │
   ▼
Amazon ECR
   │
   ▼
Amazon EKS
   │
   ├── Helm Deployments
   ├── ArgoCD GitOps
   ├── Prometheus
   ├── Grafana
   └── Loki
          │
          ▼
AWS ALB
   │
   ▼
Route53 DNS
   │
   ▼
ACM HTTPS
   │
   ▼
Users
```
