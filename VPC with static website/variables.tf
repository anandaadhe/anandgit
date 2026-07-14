variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 Key Pair Name"
}

variable "my_ip" {
  description = "Your Public IP in CIDR format"

  # Example:
  # 103.25.40.10/32
}