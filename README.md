# WordPress AWS EC2 Deployment with Terraform

Automated WordPress deployment on AWS EC2 using Terraform with multi-OS support (Amazon Linux, Ubuntu, CentOS/RHEL). This project provides a dynamic userdata script that can be integrated into existing Terraform configurations to automatically deploy WordPress instances with Apache virtual host configuration.

## 🚀 Features

- **Multi-OS Support**: Automatically detects and configures WordPress on Amazon Linux, Ubuntu, and CentOS/RHEL
- **Dynamic Configuration**: Project name and domain passed as Terraform variables
- **Apache Virtual Host**: Automatic configuration based on your domain
- **Integration Ready**: Designed to be added to existing Terraform scripts
- **Comprehensive Logging**: Full installation logs for troubleshooting


## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Terraform     │───▶│   AWS EC2        │───▶│   WordPress     │
│   Variables     │    │   Instance       │    │   + Apache      │
│                 │    │                  │    │   + PHP         │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
wordpress_userdata_terraform-main/
├── main.tf                 # Main EC2 instance configuration
├── variables.tf            # Input variables definition
├── output.tf              # Output values
├── terraform.tfvars       # Variable values (example)
├── version.tf             # Terraform and provider versions
└── wordpress_userdata.sh  # Dynamic userdata script
```

## ⚙️ Configuration

### Required Variables

| Variable | Description | Type | Example |
|----------|-------------|------|---------|
| `project_name` | Name of the WordPress project | string | `"my-wordpress-site"` |
| `project_domain` | Domain name for the WordPress site | string | `"example.com"` |



## 🔧 Integration with Existing Terraform

This module is designed to be easily integrated into existing Terraform configurations. Here's how to use it:

### Method : Direct Integration

Add the userdata script to your existing EC2 resource:

```hcl
resource "aws_instance" "your_instance" {
  # ... your existing configuration ...
  
  user_data = templatefile("${path.module}/wordpress_userdata.sh", {
    project_name   = var.project_name
    project_domain = var.project_domain
  })
}
```

## 🖥️ Supported Operating Systems

The userdata script automatically detects and configures:

- **Amazon Linux 2023** (`amzn`)
- **Ubuntu** (24 LTS)
- **CentOS/RHEL** (`centos` or `rhel`)


## 🐛 Troubleshooting

### Check Installation Logs

```bash
# View installation logs
sudo tail -f /var/log/wordpress_dynamic_install.log
```

### Common Issues

1. **WordPress not accessible**: Check security group rules for HTTP/HTTPS
2. **Domain not resolving**: Ensure DNS is pointing to the correct public IP
3. **Permission errors**: Check file ownership in `/var/www/html/your-project-name`

### Verify Apache Configuration

```bash
# Check Apache status
sudo systemctl status apache2  # Ubuntu
sudo systemctl status httpd    # Amazon Linux/CentOS

# Check virtual host configuration
sudo apache2ctl -S  # Ubuntu
sudo httpd -S       # Amazon Linux/CentOS
```

## 📝 Customization

### Adding SSL/HTTPS

To add SSL support, modify the virtual host configuration in `wordpress_userdata.sh` to include SSL directives and install certificates.

### Custom PHP Configuration

Add PHP configuration modifications in the OS-specific sections of the userdata script.

### Additional Apache Modules

Install additional Apache modules by adding them to the OS-specific installation sections.


---

**Happy WordPress Deploying! 🎉**
