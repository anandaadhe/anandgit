variable "aws_region" {
  description = "AWS region to deploy into. Free tier is available in every commercial region."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used to name/tag all resources."
  type        = string
  default     = "free-tier-demo"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone used for both subnets (keeping both in one AZ avoids any cross-AZ data-transfer charges)."
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type. t2.micro (or t3.micro where t2 isn't offered) is the AWS Free Tier eligible size: 750 hrs/month free for the first 12 months of a new account."
  type        = string
  default     = "t2.micro"
}

variable "create_private_instance" {
  description = "Whether to also launch a free-tier EC2 instance in the private subnet. Left false by default: a private instance has no route to the internet unless you add a NAT Gateway, and NAT Gateways are NOT free (~$0.045/hr + data charges). Set true only if you understand you'd need to add a NAT Gateway yourself, which will incur cost."
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "Name of an EXISTING EC2 key pair in your account to attach for SSH access. Leave as null to skip creating/attaching a key pair (you can still reach the instance via EC2 Instance Connect, which is free and needs no public key)."
  type        = string
  default     = null
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form (e.g. 1.2.3.4/32), used to restrict SSH access. Defaults to closed (no SSH access) so you don't have to supply anything; tighten/loosen as needed. Never leave this as 0.0.0.0/0 for SSH."
  type        = string
  default     = "127.0.0.1/32"
}

variable "bucket_name" {
  description = "Globally-unique name for the S3 bucket that will host the static website. Must be lowercase, no underscores. If left null, a unique name is generated automatically."
  type        = string
  default     = null
}
