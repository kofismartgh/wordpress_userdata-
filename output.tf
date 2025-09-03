#--- outputs.tf --- 

output "instance_id" {
  description = "ID of the WordPress EC2 instance"
  value       = aws_instance.wordpress.id
}
output "instance_public_ip" {
  description = "Public IP address of the WordPress instance"
  value       = aws_instance.wordpress.public_ip
}
output "instance_private_ip" {
  description = "Private IP address of the WordPress instance"
  value       = aws_instance.wordpress.private_ip
}
output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = aws_instance.wordpress.public_ip
}

# output "wordpress_url" {
# description = "URL to access WordPress (using public IP or Elastic IP)"
# value       = format("http://%s", var.create_elastic_ip ? aws_eip.wordpress[0].public_ip : aws_instance.wordpress.public_ip)
# } 
# output "wordpress_domain_url" {
# description = "WordPress domain URL (configure DNS to point to this IP)"
# value       = format("http://%s (Point DNS to: %s)", var.project_domain, var.create_elastic_ip ? aws_eip.wordpress[0].public_ip : aws_instance.wordpress.public_ip)
# } 