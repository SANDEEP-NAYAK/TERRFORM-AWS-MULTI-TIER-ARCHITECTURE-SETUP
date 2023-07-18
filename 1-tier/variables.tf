variable "public_subnet" {
    description = "public subnet for elb"
    type = list(string)
}

variable "private_subnets" {
    description = "Private subnets for elb"
    type = list(string)
}


variable "vpcId" {
    description = "vpc id for application-elb"
    type = string
}

variable "ids" {
    description = "instance ids for target grp"
    type = list(string)
}

