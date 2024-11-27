#Primary Region Configuration
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"
  cidr_block = "10.0.0.0/16"
  subnet_a_cidr = "10.0.1.0/24"
  subnet_b_cidr = "10.0.2.0/24"
  az_a = "us-east-1a"
  az_b = "us-east-1b"
}

module "ec2" {
  source = "../../modules/ec2"
  ami = "ami-xxxx"
  instance_type = "t2.medium"
  subnet_id = module.vpc.subnet_a_id
  name = "Primary EC2"
}

module "rds" {
    source = "../../modules/rds"
    storage = 20
    storage_type = "gp2"
    db_instance_class = "db.t2.micro"
    engine_version = "8.7"
    db_instance_identifier = "primary-db"
    db_username = "admin"
    db_password = "password"
    db_name = "primarydb"
    multi_az = true
    az = "us-east-1a"
    az_replica = "us-east-1b"
    security_group_id = "sg-xxxx"
    db_instance_identifier_replica = "primary-db-replica"
}

module "s3" {
    source = "../../modules/s3"
    bucket_name = "primary-backup-bucket"
    replica_bucket = "secondary-backup-bucket"
}
