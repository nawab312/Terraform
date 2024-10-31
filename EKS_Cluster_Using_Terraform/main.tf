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

