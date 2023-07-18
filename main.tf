module "vpc-network" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "12.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["12.0.4.0/24", "12.0.5.0/24", "12.0.6.0/24"]
  public_subnets  = ["12.0.1.0/24", "12.0.2.0/24", "12.0.3.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "tier-1-elb-asg" {
  source          = "./1-tier"
  public_subnet   = module.vpc-network.public_subnets
  private_subnets = module.vpc-network.private_subnets

  vpcId = module.vpc-network.vpc_id
  ids   = module.tier-2-ec2.instance_ids
}

module "tier-2-ec2" {
  source           = "./2-tier"
  vpc_id           = module.vpc-network.vpc_id
  private_subnets  = module.vpc-network.private_subnets
  azs              = module.vpc-network.azs
  pub_azs          = module.vpc-network.public_subnets
  load-balancer-sg = module.tier-1-elb-asg.lb_security
}


module "tier-3-db" {
  source      = "./3-tier"
  db_az       = module.vpc-network.azs[0]
  storage     = 10
  name        = "web_db"
  engine      = "mysql"
  eng_version = "5.7"
  ins_class   = "db.t3.micro"
}