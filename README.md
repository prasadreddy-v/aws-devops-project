# aws-devops-project


It will include:

Project overview
Architecture
Repository structure
AWS infrastructure
Terraform
EKS
CI/CD
Helm
Monitoring
ALB Controller
ExternalDNS
ACM + Route53
ArgoCD GitOps
Logging stack (planned/completing phase)
Complete command flow
Future improvements

You can directly copy this into your README.md.

AWS EKS DevOps Platform - End to End Implementation
Project Overview

This project demonstrates a complete production-style DevOps implementation on AWS.

The objective was to deploy a containerized Flask application on Amazon EKS with:

Infrastructure as Code using Terraform
Container image management using Amazon ECR
CI/CD automation using GitHub Actions
Kubernetes deployment using Helm
Monitoring using Prometheus and Grafana
Application Load Balancing using AWS ALB Controller
DNS automation using ExternalDNS
HTTPS using ACM certificates
GitOps deployment using ArgoCD
Centralized logging using Loki + Promtail
High Level Architecture
                 Developer
                    |
                    |
                GitHub Repo
                    |
                    |
            GitHub Actions CI/CD
                    |
          ---------------------
          |                   |
          |                   |
        Docker              Terraform
          |                   |
          |                   |
        AWS ECR             AWS VPC
                              |
                              |
                           EKS Cluster
                              |
        ------------------------------------------------
        |                    |                         |
     Helm App            Monitoring               GitOps
        |                    |                         |
    Flask App          Prometheus/Grafana          ArgoCD
        |
        |
    ALB Controller
        |
        |
    AWS Application Load Balancer
        |
        |
    ExternalDNS
        |
        |
    Route53
        |
        |
    ACM HTTPS Certificate
Repository Structure
aws-devops-project
|
├── terraform
│   |
│   ├── vpc
│   ├── eks
│   ├── iam
│   └── environments
│
├── application
│   |
│   ├── Dockerfile
│   └── Flask application
│
├── kubernetes
│   |
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── helm
│   |
│   └── flask-app
│       |
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates
│
├── alb-controller
│
├── external-dns
│
├── argocd
│
├── logging
│
└── .github
    |
    └── workflows
Phase 1: AWS Account Preparation

Required tools:

Installed:

AWS CLI
Terraform
kubectl
Helm
eksctl
Docker
Git

AWS configuration:

aws configure

Verify:

aws sts get-caller-identity
Phase 2: Infrastructure Provisioning Using Terraform

Terraform created:

VPC

Components:

VPC
Public subnets
Private subnets
Internet Gateway
NAT Gateway
Route Tables

Architecture:

VPC

10.0.0.0/16

|
|-- Public Subnets
|
|-- Private Subnets
       |
       |
      EKS Nodes

Terraform deployment:

terraform init

terraform plan

terraform apply

Outputs:

cluster_name
vpc_id
public_subnet_ids
private_subnet_ids
Phase 3: EKS Cluster Setup

Verify cluster:

aws eks list-clusters \
--region ap-south-1

Cluster:

devops-eks

Status:

aws eks describe-cluster \
--name devops-eks \
--region ap-south-1 \
--query cluster.status

Output:

ACTIVE

Configure kubectl:

aws eks update-kubeconfig \
--name devops-eks \
--region ap-south-1

Verify:

kubectl get nodes

Output:

Ready
Phase 4: Containerization

Docker image created:

flask-app

Build:

docker build -t flask-app .

Run locally:

docker run -p 5000:5000 flask-app
Phase 5: Amazon ECR Setup

Repository:

flask-app

Login:

aws ecr get-login-password \
--region ap-south-1 |
docker login \
--username AWS \
--password-stdin <ACCOUNT>.dkr.ecr.ap-south-1.amazonaws.com

Build:

docker build \
-t flask-app .

Tag:

docker tag flask-app \
<ECR_URL>/flask-app:latest

Push:

docker push \
<ECR_URL>/flask-app:latest
Phase 6: GitHub Actions CI/CD

Pipeline performs:

Git Push

     |
     |
GitHub Actions

     |
     |
Docker Build

     |
     |
Push Image

     |
     |
Deploy Kubernetes

Workflow:

.github/workflows

microservice-ci.yaml
deploy.yaml

Actions:

Checkout code
Configure AWS
Login ECR
Build image
Push image
Update deployment
Phase 7: Kubernetes Deployment

Created:

deployment.yaml

service.yaml

Deployment:

kubectl apply -f deployment.yaml

Service:

kubectl apply -f service.yaml

Verify:

kubectl get pods

kubectl get svc

Application exposed through:

AWS LoadBalancer Service
Phase 8: Helm Packaging

Created Helm chart:

helm/flask-app

Structure:

flask-app

Chart.yaml

values.yaml

templates/

deployment.yaml

service.yaml

Validate:

helm lint flask-app

Install:

helm install flask-app ./helm/flask-app

Verify:

helm list

kubectl get pods
Phase 9: Monitoring Setup

Installed:

kube-prometheus-stack

Components:

Prometheus
Grafana
AlertManager
Node Exporter

Namespace:

monitoring

Install:

helm install monitoring \
prometheus-community/kube-prometheus-stack \
-n monitoring

Verify:

kubectl get pods -n monitoring
Phase 10: AWS Load Balancer Controller

Purpose:

Creates AWS ALB automatically from Kubernetes Ingress.

Installed:

aws-load-balancer-controller

Created:

IAM Policy
IAM Role
IRSA
Service Account

Verify:

kubectl get pods -n kube-system

Expected:

aws-load-balancer-controller Running
Phase 11: Application Ingress

Ingress:

flask-app-ingress

Annotations:

alb.ingress.kubernetes.io/scheme: internet-facing

alb.ingress.kubernetes.io/target-type: ip

Result:

Kubernetes Ingress

↓

AWS ALB

Verify:

kubectl get ingress
Phase 12: HTTPS Configuration

ACM Certificate:

arn:aws:acm:ap-south-1:
523835808362:
certificate/
3953292e-8ded-4c45-b8f6-754579449b32

Ingress annotations:

alb.ingress.kubernetes.io/certificate-arn

alb.ingress.kubernetes.io/listen-ports:
[{"HTTP":80},{"HTTPS":443}]

alb.ingress.kubernetes.io/ssl-redirect: "443"

Result:

https://app.mydevop.net
Phase 13: ExternalDNS

Purpose:

Automatically creates Route53 records.

Flow:

Kubernetes Ingress

        |

ExternalDNS

        |

Route53

        |

app.mydevop.net

Installed:

helm install external-dns \
external-dns/external-dns \
-n kube-system

Configuration:

domain-filter=mydevop.net

Result:

Automatically creates:

app.mydevop.net
Phase 14: ArgoCD GitOps

Installed:

ArgoCD

Namespace:

argocd

Install:

helm repo add argo \
https://argoproj.github.io/argo-helm


helm install argocd \
argo/argo-cd \
-n argocd

Verify:

kubectl get pods -n argocd

Components:

Application Controller

Repo Server

API Server

Redis

Dex

GitOps Flow:

Developer

 |

GitHub

 |

ArgoCD

 |

Kubernetes

 |

Application

Future deployment:

git push

↓

ArgoCD detects change

↓

Automatic sync

↓

New deployment
Phase 15: Centralized Logging (Implementation Pending)
Objective

Collect Kubernetes application logs centrally.

Stack:

Flask Container

       |

Container stdout

       |

Promtail

       |

Loki

       |

Grafana

Components:

Loki

Stores logs.

Promtail

Collects logs from Kubernetes nodes.

Grafana

Visualizes logs.

Install:

helm repo add grafana \
https://grafana.github.io/helm-charts

Install Loki:

helm install loki \
grafana/loki-stack \
-n logging

Install Promtail:

helm install promtail \
grafana/promtail \
-n logging

Verify:

kubectl get pods -n logging

Grafana:

Add datasource:

Loki

Query:

{namespace="default"}
Current Completed Status
Component	Status
Terraform	Completed
VPC	Completed
EKS	Completed
Docker	Completed
ECR	Completed
GitHub Actions	Completed
Kubernetes Deployment	Completed
Helm	Completed
Prometheus	Completed
Grafana Monitoring	Completed
ALB Controller	Completed
ACM HTTPS	Completed
Route53	Completed
ExternalDNS	Completed
ArgoCD Installation	Completed
GitOps Sync	Next
Loki Logging	Next
Final Production Architecture
GitHub
 |
 |
GitHub Actions
 |
 |
ECR
 |
 |
EKS
 |
 |
Helm / ArgoCD
 |
 |
Flask Application
 |
 +----------------+
 |                |
ALB             Logs
 |                |
Route53         Loki
 |
ACM HTTPS
 |
Users