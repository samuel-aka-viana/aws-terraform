output "instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.instance_dsa.*.id

}
