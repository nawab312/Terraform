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