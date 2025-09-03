#--- variables.tf --- 

variable "project_name" {
  description = "Name of the WordPress project"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.project_name))
    error_message = "Project name must contain only alphanumeric characters, hyphens, and underscores."
  }
}
variable "project_domain" {
  description = "Domain name for the WordPress site"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z]{2,})+$", var.project_domain))
    error_message = "Please provide a valid domain name."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "vpc_id" {
  description = "VPC ID where the instance will be launched"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
variable "ami_id" {
  description = "AMI ID for the EC2 instance. If empty, will use latest Amazon Linux 2023"
  type        = string
  #default     = "ami-00ca32bbc84273381" - amazon linux
  default     = "ami-0360c520857e3138f" #- ubuntu
}
variable "key_pair_name" {
  description = "Name of the AWS key pair for SSH access"
  type        = string
}
variable "associate_public_ip" {
  description = "Whether to associate a public IP address with the instance"
  type        = bool
  default     = true
}
variable "root_volume_type" {
  description = "Type of root EBS volume"
  type        = string
  default     = "gp3"
}
variable "root_volume_size" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 20
}
variable "enable_volume_encryption" {
  description = "Enable EBS volume encryption"
  type        = bool
  default     = true
}
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
