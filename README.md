Terraform AWS Project

Overview

This Terraform project automates the provisioning of AWS resources, including an EC2 instance, S3 bucket, and IAM roles. It follows Infrastructure as Code (IaC) principles to ensure consistency and repeatability.

Prerequisites

Terraform installed (Download Here)

AWS CLI installed and configured (Installation Guide)

An AWS account with necessary permissions

AWS Resources Created

EC2 Instance: Virtual machine hosted on AWS

S3 Bucket: Storage for logs, artifacts, and backups

IAM Roles: Used for secure access to AWS services

Setup & Usage

1️⃣ Clone the Repository

git clone https://github.com/your-repo/terraform-aws-project.git
cd terraform-aws-project

2️⃣ Initialize Terraform

terraform init

3️⃣ Plan Deployment

terraform plan

4️⃣ Apply Changes

terraform apply

Confirm with yes when prompted.

5️⃣ Destroy Resources (If Needed)

terraform destroy

Confirm with yes when prompted.

Best Practices

Use IAM Roles Instead of Access Keys

Store Terraform State Securely (e.g., S3, Terraform Cloud)

Follow AWS Security Best Practices