variable "vpc_id" {
    description = "VPC id for the security group"
    type = string
}

variable "private_subnets" {
    description = "Private subents for the deployments of ec2"
    type = list
}

variable "azs" {
    description = "Availability zones for ec2"
    type = list
}

variable "pub_azs" {
    type = list
}

variable "load-balancer-sg" {}