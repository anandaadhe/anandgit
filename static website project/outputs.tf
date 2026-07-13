output "s3_website_endpoint" {
  description = "URL of the static website hosted on S3"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "public_ec2_public_ip" {
  description = "Public IP of the EC2 instance in the public subnet"
  value       = aws_instance.public_web.public_ip
}

output "public_ec2_website_url" {
  description = "Simple HTTP page served by the public EC2 instance"
  value       = "http://${aws_instance.public_web.public_ip}"
}

output "private_ec2_private_ip" {
  description = "Private IP of the optional private EC2 instance (only set if create_private_instance = true)"
  value       = length(aws_instance.private_app) > 0 ? aws_instance.private_app[0].private_ip : null
}
