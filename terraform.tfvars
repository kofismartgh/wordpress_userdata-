
project_name   = "hope-temp"
project_domain = "hope.solotest.win"
environment    = "dev"
region         = "us-east-1"
#Network configuration
vpc_id    = "vpc-07539f61"
subnet_id = "subnet-0b465f80a24e8a503"
#Instance configuration
instance_type = "t3.micro"
key_pair_name = "kofismart"
#Optional configurations

associate_public_ip        = true
root_volume_size           = 20
enable_volume_encryption   = true
enable_detailed_monitoring = false
common_tags = {
  Owner       = "SRE"
  ManagedBy   = "Terraform"
  Environment = "dev"
  Project     = "WordPress"
} 