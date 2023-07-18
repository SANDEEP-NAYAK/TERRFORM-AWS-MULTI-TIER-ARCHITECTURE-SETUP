# TERRFORM-AWS-MULTI-TIER-ARCHITECTURE-SETUP
3 tier architecture implemented for hosting an website by terraform keeping best practices in light.

This project is made from the sole purpose of implementing terraform concepts and best practices.
This project is totally based on modular approach.
 
 It showcases the implementation of 3-tier architecture.
 Presentation Layer(1st-tier): consists of load balancer and autoscaling group present in public subnets
 Application Layer(2nd tier): consists of 3 instances one in each private subnets and one Bastion host in a public subnet.
 Database Layer(3rd tier): A RDS mysql databases is configured in a private subnet. Used AWS secrets Manager for storing DB's username and password.

The VPC is created using a module from terraform module registry.
