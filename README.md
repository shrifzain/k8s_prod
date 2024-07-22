# Production-Ready Kubernetes Application with Full-Stack Tech Stack

This project outlines the development and deployment of a production-ready, full-stack application using a modern technology stack and containerized infrastructure on AWS. It focuses on scalability, security, and high availability, ensuring robust performance and streamlined management.

## Tech Stack

- **Frontend**: React
- **Backend**: Node.js
- **Database**: MySQL (Amazon RDS)
- **Container Orchestration**: Kubernetes (Amazon EKS)

## Infrastructure

- **Cloud Provider**: AWS
- **Networking**: VPC with custom subnets, NAT gateways, and CIDR blocks
- **Containerization**: Docker
- **Container Orchestration**: Amazon EKS
- **Database**: Amazon RDS (MySQL)
- **Load Balancing**: AWS Load Balancer
- **DNS Management**: Amazon Route 53

## Kubernetes Platform

- **Secrets Management**: AWS Secrets Manager
- **Ingress & Certificates**: Ingress Controller and Cert Manager
- **Observability**: Prometheus, Grafana, and Loki
- **Security**: Trivy & SonarQube

## CI/CD Pipeline

- **Automation Tool**: Jenkins
- **Pipeline**: Automated build, test, and deployment pipeline for continuous integration and continuous delivery (CI/CD)

## Key Features

### Scalability

- **EKS Auto-Scaling**: Automatically scales application resources based on traffic, ensuring optimal performance.

### Security

- **Secrets Management**: Secure storage of sensitive data with AWS Secrets Manager.
- **SSL/TLS Certificates**: Automated provisioning and management with Cert Manager.
- **Vulnerability Scanning**: Regular scans of container images with Trivy.
- **Code Quality Checks**: Continuous assessment of code quality with SonarQube.

### High Availability

- **Database Replication**: MySQL replication across availability zones using RDS for fault tolerance.
- **Load Balancing**: AWS Load Balancer distributes traffic across healthy instances, maintaining service availability.

### Observability

- **Monitoring & Alerting**: Comprehensive monitoring and alerting with Prometheus and Grafana.
- **Log Aggregation**: Efficient log aggregation and troubleshooting with Loki.

## Getting Started

This section provides detailed instructions for setting up the infrastructure, deploying applications, and configuring various services on AWS and EKS.

### Prerequisites

- AWS Account
- Kubernetes CLI
- Helm

### Deployment Steps

#### Infrastructure Setup

1. **VPC Configuration**: Set up VPC with custom subnets and NAT gateways in AWS.
2. **EKS Cluster Creation**: Create an EKS cluster across multiple availability zones for high availability.
3. **Amazon RDS Setup**: Configure Amazon RDS with a high availability setup for the MySQL database.
4. **Load Balancer Configuration**: Set up AWS Load Balancer to manage traffic distribution.
5. **Route 53 Setup**: Configure Route 53 for domain management and routing.

#### Application Deployment

1. **Frontend & Backend Deployment**: Deploy the React frontend and Node.js backend applications to the EKS cluster.
2. **Database Connectivity**: Ensure the backend is connected to the MySQL database on RDS.

#### Security Configuration

1. **Secrets Management**: Integrate AWS Secrets Manager for secure handling of sensitive data.
2. **Ingress & Certificates**: Install and configure the Ingress controller and Cert Manager for secure application access.

#### Monitoring & Logging

1. **Observability Stack**: Deploy Prometheus, Grafana, and Loki for monitoring and logging of application performance and health.

#### Security Scanning

1. **Continuous Security & Code Quality**: Utilize Trivy for vulnerability scanning and SonarQube for code quality checks.

## CI/CD Pipeline Setup

1. **Jenkins Installation**: Install Jenkins on a dedicated server or as a container.
2. **Pipeline Configuration**: Set up Jenkins pipeline to automate build, test, and deployment processes.
3. **Integration**: Integrate Jenkins with your Git repository, Docker registry, and Kubernetes cluster for seamless CI/CD.


### Execution checklist
- [x] Terraform
	- [x] Create an Administrator User in AWS
	- [x] Configure local CLI with the Administrator User credentials
	- [x] Set up a Terraform S3 Bucket for state storage
	- [x] Set up DynamoDB for state locking and consistency
- [x] infra
	- [x] foundation
 		- [x] Vpc 
		- [x] Configure CIDR blocks
		- [x] Set up two Availability Zones 
		- [x] Intra, Private subnet, Public Subnet
		- [x] Configure a NAT Gateway for internet access in Private subnets
       
		
	- [x] EKS
		- [x] Configure VPC-CNI and IRSA to create IAM roles allowing EKS to manage load balancers
		- [x] Set up Node Groups with Manage DNS records to point to your application resources.
	auto-scaling capabilities
		- [x] Configure EBS-CSI and IRSA with IAM roles for persistent storage
	- [x] EKS Plateform Applications
		- [x] Install Nginx Ingress Controller for external load balancing
		- [x] Install Cert-Manager to manage and renew SSL certificates
  	- [x] RDS
  		- [x] Secret manager
		- [x] Parameter groups
		- [x] Security groups
		- [x] mysql
	- [x] S3 
        
      
         

- [x] App	
	- [x] backend
	     - Configure application settings to integrate with MYSQL
	     - Create Kubernetes manifest files for deployment
        - [x] frontend
	- [x] Databases
	     - Configure database access, handling user credentials and connection endpoints
	     - Create Kubernetes manifest files including Persistent Volume Claims (PVC), Storage Classes, Secrets, Services, and Deployments for:
	  - [x] mysql Server
	 

 
