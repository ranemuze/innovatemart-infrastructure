# EKS Terraform Assessment - Task 3.1

This repository contains the Terraform configuration for setting up an AWS EKS cluster and all required networking and IAM resources as part of Task 3.1 of the Cloud DevOps assessment.

## Terraform Configuration (`main.tf`)

The `main.tf` file provisions the following AWS resources:

- **VPC** with public and private subnets across 2 availability zones
- **EKS Cluster** with proper security groups
- **IAM Roles and Policies** for the EKS cluster and node groups
- **NAT Gateways** for private subnet internet access
- **Internet Gateway** for public subnet access

## Steps Taken

1. **Installed Tools**  
   - Terraform  
   - AWS CLI

2. **Configured AWS CLI**  
   ```bash
   aws configure
Set AWS Access Key, Secret Key, and default region (eu-west-1).

Wrote main.tf

Defined VPC, subnets, and internet/NAT gateways.

Created IAM roles and policies for EKS cluster and node groups.

Defined the EKS cluster resource with node groups.

Initialized Terraform

bash
Copy code
terraform init
Validated the Plan

bash
Copy code
terraform plan
Ensured that all resources would be created as expected.

Applied the Configuration

bash
Copy code
terraform apply
Confirmed creation of all AWS resources in the console.

Verified Deployment

Checked that VPC, subnets, NAT gateways, Internet Gateway, IAM roles, and the EKS cluster were all successfully created.

