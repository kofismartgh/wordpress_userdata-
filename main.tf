resource "aws_instance" "wordpress" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  subnet_id              = var.subnet_id
  vpc_security_group_ids = ["sg-0f3bbadc059e1ebce"]
  iam_instance_profile   = "ec2ssmrole"


  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = var.enable_volume_encryption
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/userdata/wordpress_userdata.sh", {
    project_name   = var.project_name
    project_domain = var.project_domain
  })

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-wordpress-server"
      Environment = var.environment
      Project     = var.project_name
      Domain      = var.project_domain
    }
  )

  user_data_replace_on_change = true
}
