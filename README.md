# SecOPS-CoPilot - Terraform Infrastructure

This Terraform project creates a complete AWS infrastructure for a web application with the following components:

## Infrastructure Components

- **VPC** with public and private subnets across 2 availability zones
- **Internet Gateway** for public subnet internet access
- **NAT Gateway** for private subnet internet access
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** with EC2 instances
- **Security Groups** for load balancer and EC2 instances
- **IAM Role and Instance Profile** for EC2 instances
- **CloudWatch Alarms** for auto-scaling
- **Key Pair** for SSH access

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** version >= 1.0
3. **SSH Key Pair** for EC2 instance access

## Quick Start

### 1. Generate SSH Key Pair

```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/SecOPS-CoPilot
```

### 2. Update Configuration

Edit `terraform.tfvars` and replace the `ssh_public_key` with your actual public key:

```bash
# Copy your public key content
cat ~/.ssh/SecOPS-CoPilot.pub
```

Then update the `ssh_public_key` variable in `terraform.tfvars`.

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan the Deployment

```bash
terraform plan
```

### 5. Apply the Infrastructure

```bash
terraform apply
```

### 6. Access Your Application

After successful deployment, you can access your application using the load balancer DNS name from the outputs:

```bash
terraform output load_balancer_dns_name
```

## File Structure

```
.
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── outputs.tf          # Output values
├── iam.tf              # IAM resources
├── user_data.sh        # EC2 instance initialization script
├── terraform.tfvars    # Variable values
└── README.md           # This file
```

## Configuration

### Key Variables

- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name used for resource naming (default: SecOPS-CoPilot)
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `instance_type`: EC2 instance type (default: t3.micro)
- `desired_capacity`: Number of EC2 instances (default: 2)
- `ssh_cidr`: CIDR block for SSH access (default: 0.0.0.0/0)

### Security Notes

⚠️ **Important Security Considerations:**

1. The default `ssh_cidr` allows SSH access from anywhere (0.0.0.0/0). In production, restrict this to your IP address or VPN CIDR.
2. Replace the default SSH public key with your own key pair.
3. Consider enabling HTTPS on the load balancer for production use.

## Architecture

```
Internet
    │
    ▼
┌─────────────────┐
│   Load Balancer │
└─────────────────┘
    │
    ▼
┌─────────────────┐    ┌─────────────────┐
│  Public Subnet  │    │  Public Subnet  │
│   (AZ-1a)       │    │   (AZ-1b)       │
└─────────────────┘    └─────────────────┘
    │                        │
    ▼                        ▼
┌─────────────────┐    ┌─────────────────┐
│ Private Subnet  │    │ Private Subnet  │
│   (AZ-1a)       │    │   (AZ-1b)       │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   EC2       │ │    │ │   EC2       │ │
│ │ Instance    │ │    │ │ Instance    │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
    │                        │
    └────────────┬───────────┘
                 ▼
         ┌─────────────────┐
         │  NAT Gateway    │
         └─────────────────┘
                 │
                 ▼
         ┌─────────────────┐
         │ Internet Gateway│
         └─────────────────┘
                 │
                 ▼
              Internet
```

## Outputs

After deployment, Terraform will output:

- Load balancer DNS name
- VPC and subnet IDs
- Security group IDs
- Auto Scaling Group name
- NAT Gateway information
- Key pair name

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **AMI not found**: Update the `ami_id` in `terraform.tfvars` for your region
2. **Availability zones**: Ensure the specified AZs exist in your region
3. **SSH access**: Verify your SSH key pair is correctly configured

### Health Checks

The application includes a health check endpoint at `/health` that returns a simple "OK" response.

### Logs

EC2 instances log startup information to `/var/log/instance-startup.log`.

## Cost Optimization

- Use `t3.micro` instances for development/testing
- Consider using Spot instances for cost savings
- Monitor CloudWatch metrics for resource utilization
- Use appropriate instance types based on your workload

## Security Best Practices

1. Restrict SSH access to specific IP ranges
2. Use HTTPS for production applications
3. Implement proper IAM policies
4. Enable VPC Flow Logs for network monitoring
5. Use AWS Secrets Manager for sensitive data
6. Regularly update AMIs and security patches 