ECS Terraform Project - Hosting a Secure Docker App with Load Balancer and DNS

🚀 Overview

This project provisions a full AWS ECS infrastructure using Terraform to deploy a containerized web application. The app is load-balanced with HTTPS using a domain and Route53.

🌐 What This Project Deploys

A VPC with 2 public subnets

An Internet Gateway and route tables

Security groups for ECS and ALB

An ECS cluster with a Fargate service and task definition

An Application Load Balancer (ALB) with listeners (HTTP & HTTPS)

ACM Certificate and Route53 DNS records

Secrets Manager integration for DockerHub credentials

CloudWatch Logs for container logging

🧰 Files Breakdown

File

Description

main.tf

Core AWS infrastructure (VPC, Subnets, IGW, ECS)

outputs.tf

Optional outputs (not yet customized)

variables.tf

Input variables (if added in future)

DNS.tf

DNS, ACM certificate, and Route53 configuration

📅 Step-by-Step Setup

1. Initial Setup

Installed Terraform & configured AWS CLI.

Created a public VPC, two subnets, internet gateway, and route table.

2. Security Groups

One SG for the ECS tasks (allowed port 5002)

One SG for the ALB (allowed port 443)

3. ECS Configuration

Created ECS cluster and task definition

Used Fargate launch type

Pulled a private image from DockerHub using Secrets Manager credentials

4. Logging

Enabled CloudWatch logging in the task definition

5. ALB + Target Group

Created ALB spanning two subnets

Configured Target Group with health checks

Linked ALB to ECS via load balancer block

6. DNS & HTTPS Setup

Bought domain abdikarim.co.uk

Requested ACM certificate with DNS validation

Created validation record via Route53

Created ALB listeners for:

HTTP (port 80) redirects to HTTPS

HTTPS (port 443) forwards to ECS app

Added Route53 Alias A Record to point to ALB

🤦🏾‍ Challenges Faced & Lessons Learned

Challenge

Solution

Getting HTTPS to work with ALB

Needed to request ACM cert and validate via DNS

ALB not forwarding to ECS

Health check port/path mismatch was breaking routing

Route53 not linking properly

Misunderstood alias config initially

Understanding IAM roles

Used jsonencode() and ChatGPT to help write trust policy

Pushing private image from DockerHub

Learned to use Secrets Manager with repositoryCredentials

Troubleshooting

Used terraform apply -auto-approve and logs to debug service startup

🚀 Things I Want to Improve

Parameterize configs using variables.tf

Add output values for future modules

Automate DNS + SSL setup even more

Add monitoring via CloudWatch alarms

🎓 What I Learned

Deep understanding of ECS, ALB, Route53, ACM, IAM, Secrets Manager

How AWS services integrate through Terraform

Troubleshooting infrastructure issues through logs & ChatGPT guidance

The importance of modular, reusable IaC

🌟 Author

Abdikarim YusufDevOps Enthusiast | Cloud Learner | Automation LoverLinkedIn | GitHub

This project was a major milestone in my DevOps learning journey, blending cloud infrastructure, containerization, and automation. Proud to have built and debugged this from scratch with the help of research and community tools like ChatGPT. 🚀
