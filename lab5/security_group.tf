module "container-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name = "${var.project_name}-${var.env}-ecs-sg"

  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.container_port
      to_port     = var.container_port
      protocol    = "tcp"
      description = "con sg ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
  tags = {
    Name = "${var.project_name}-${var.env}-ecs-sg"
  }
}

module "alb-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name = "${var.project_name}-${var.env}-alb-sg"

  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.alb_sg_port
      to_port     = var.alb_sg_port
      protocol    = "tcp"
      description = "elb sg ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]
  tags = {
    Name = "${var.project_name}-${var.env}-alb-sg"
  }
}
