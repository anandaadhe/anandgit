output "public_ip" {

  value = aws_instance.web.public_ip

}

output "website" {

  value = "http://${aws_instance.web.public_ip}"

}