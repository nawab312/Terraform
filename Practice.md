You need to create a Terraform configuration that dynamically provisions multiple IAM users with different policies based on a list of users.
- Use a dynamic block to create IAM users from a given list.
- Assign different IAM policies based on user roles (e.g., Admin gets full access, Developer gets read-only access).
- Implement a conditional statement to create an IAM group only if the user count is greater than 5.

```hcl
provider "aws" {
  region = "us-east-1"
}

variable "users" {
  type = list(object({
    name = string
    role = string
  }))
  default = [
    { name = "alice", role = "Admin" },
    { name = "bob", role = "Developer" },
    { name = "charlie", role = "Developer" },
    { name = "dave", role = "Admin" },
    { name = "eve", role = "Developer" },
    { name = "frank", role = "Admin" }
  ]
}

# IAM Policy Attachments
data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "developer" {
  name = "ReadOnlyAccess"
}

# Create IAM Users
resource "aws_iam_user" "users" {
  for_each = { for user in var.users : user.name => user }
  name     = each.key
}

# Attach Policies Dynamically
resource "aws_iam_user_policy_attachment" "policy_attachment" {
  for_each   = { for user in var.users : user.name => user }
  user       = each.key
  policy_arn = each.value.role == "Admin" ? data.aws_iam_policy.admin.arn : data.aws_iam_policy.developer.arn
}

# Create IAM Group only if users count > 5
resource "aws_iam_group" "developers" {
  count = length(var.users) > 5 ? 1 : 0
  name  = "DevelopersGroup"
}

# Add Developer users to the IAM Group
resource "aws_iam_group_membership" "developer_group_membership" {
  count = length(var.users) > 5 ? 1 : 0
  name  = "dev-group-membership"
  group = aws_iam_group.developers[0].name

  users = [for user in var.users : user.name if user.role == "Developer"]
}
```

---

### EKS Cluster Using Terraform ###

```hcl
provider "aws" {
    region = "us-east-1"
}

data "aws_availability_zones" "available" {
    filter {
      name = "opt-in-status"
      values = ["opt-in-not-required"]
    }
}

/*
filter block: The filter block applies filters to narrow down the AZs based on certain criteria.
name = "opt-in-status": AWS uses the opt-in-status attribute to indicate if an Availability Zone requires users to explicitly opt in to use it.
values = ["opt-in-not-required"]: This value filters for AZs where opt-in is not required, meaning that these AZs are available for general use without any additional action.
*/

locals {
    cluster_name = "my-eks-cluster"
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.8.1"
    name = "eks-vpc"
    cidr = "10.0.0.0/16"
    azs = slice(data.aws_availability_zones.available.names, 0, 2)

    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true

    public_subnet_tags = {
      "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
      "kubernetes,io/role/internal-elb" = 1
    }
}

module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "20.8.5"
    cluster_name = local.cluster_name
    cluster_version = "1.29"

    cluster_endpoint_public_access = true
    #Makes EKS Cluster's endpoint accessible over public internet.This allows users and applications to access the Kubernetes API server from outside the VPC 
    enable_cluster_creator_admin_permissions = true

    cluster_addons = {
        aws-ebs-csi-driver = {
            service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
        }
    }
    /*
    aws-ebs-csi-driver: This specifies the AWS EBS (Elastic Block Store) Container Storage Interface (CSI) driver add-on. 
    The EBS CSI driver is a Kubernetes add-on that enables the EKS cluster to dynamically manage and attach EBS volumes to pods as persistent storage.

    service_account_role_arn: This is the IAM role ARN (Amazon Resource Name) associated with the service account that the EBS CSI driver will use. 
    By specifying the IAM role here, the CSI driver can access AWS services (like EBS) as required for its functionality.
    */

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    eks_managed_node_group_defaults = {
        ami_type = "AL2_x86_64"
    }

    eks_managed_node_groups = {
        one = {
            name = "node-group-1"
            instance_types = ["t3.small"]

            min_size = 1
            max_size = 1
            desired_size = 1
        }

        two = {
            name = "node-group-2"
            instance_types = ["t3.small"]

            min_size = 1
            max_size = 1    
            desired_size = 1
        }
    }
}

data "aws_iam_policy" "ebs_csi_policy" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

output "cluster_endpoint" {
    description = "Endpoint of EKS Contol Plane"
    value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
    description = "Security Group Ids attached to Control Plane"
    value = module.eks.cluster_security_group_id
}

output "region" {
    value = "us-east-1"
}

output "cluster_name" {
    value = module.eks.cluster_name
}

#Access your cluster with
#aws eks --region <region> update-kubeconfig --name <cluster_name>
```
---
