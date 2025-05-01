module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "ecs-vpc"
  # CIDR block for the VPC
  cidr = var.vpc_cidr_block

  azs             = [var.azail_zone_1, var.azail_zone_2]
  public_subnets  = [var.public_subnet_1_cidr_block, var.public_subnet_2_cidr_block]
  private_subnets = [var.private_subnet_1_cidr_block]

  private_subnet_tags         = { Name = "${var.project_name}-${var.env}-private-subnet" }
  public_acl_tags             = { Name = "${var.project_name}-${var.env}-public-subnet" }
  igw_tags                    = { Name = "${var.project_name}-${var.env}-igw" }
  default_security_group_tags = { Name = "${var.project_name}-${var.env}-default-sg" }
  default_route_table_tags    = { Name = "${var.project_name}-${var.env}-default-rtb" }
  public_route_table_tags     = { Name = "${var.project_name}-${var.env}-public-rtb" }

  tags = {
    Name = "${var.project_name}-${var.env}-vpc"
  }
}
