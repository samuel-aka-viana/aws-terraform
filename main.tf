module "dsa_ec2_instances" {
  source = "./modules/ec2-instances"

  instance_count = var.instance_count
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  subnet         = var.subnet_id
}

module "dsa_s3_bucket" {
  source      = "./modules/s3-bucket"
  bucket_name = var.bucket_name
  tags        = var.tags
}
