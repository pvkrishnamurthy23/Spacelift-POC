# Spacelift Setup Guide

This guide explains how to adapt the Terraform code for use with Spacelift Infrastructure as Code (IaC) platform.

## Changes Required for Spacelift

### 1. Remove terraform.tfvars from Version Control

The `terraform.tfvars` file should not be committed to version control when using Spacelift. Instead, variables will be managed through Spacelift's UI.

**Action**: Add `terraform.tfvars` to `.gitignore` (already done)

### 2. Update .gitignore for Spacelift

```gitignore
# Spacelift specific
.spacelift/
spacelift.yaml
```

### 3. Create Spacelift Stack Configuration

The `spacelift.yaml` file has been created to define the stack configuration.

## Spacelift Setup Steps

### Step 1: Connect Your Repository

1. **Login to Spacelift** and navigate to your account
2. **Add a new stack** by connecting your Git repository
3. **Select the repository** containing this Terraform code
4. **Choose the branch** (usually `main` or `master`)

### Step 2: Configure Stack Settings

In the Spacelift UI, configure the following:

#### Basic Settings:
- **Stack Name**: `spacelift-poc`
- **Project Root**: `.` (root directory)
- **Terraform Version**: `1.5.0` or latest
- **Branch**: `main`

#### Environment Variables:
Set these in the Spacelift UI under "Environment Variables":

```
TF_VAR_aws_region=us-east-1
TF_VAR_project_name=spacelift-poc
TF_VAR_environment=dev
```

#### Terraform Variables:
Set these in the Spacelift UI under "Terraform Variables":

**Non-sensitive variables:**
```
aws_region = "us-east-1"
project_name = "spacelift-poc"
environment = "dev"
vpc_cidr = "10.0.0.0/16"
instance_type = "t3.micro"
desired_capacity = "2"
min_size = "1"
max_size = "4"
public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
ami_id = "ami-0c02fb55956c7d316"
```

**Sensitive variables (mark as sensitive in UI):**
```
ssh_public_key = "YOUR_SSH_PUBLIC_KEY_HERE"
ssh_cidr = "0.0.0.0/0"
```

### Step 3: Configure AWS Credentials

#### Option A: AWS Access Keys (for testing)
1. Go to "Stack Settings" → "Environment Variables"
2. Add:
   ```
   AWS_ACCESS_KEY_ID=your_access_key
   AWS_SECRET_ACCESS_KEY=your_secret_key
   ```

#### Option B: AWS Role (recommended for production)
1. Create an IAM role in AWS with necessary permissions
2. Configure Spacelift to assume this role
3. Set the role ARN in Spacelift settings

### Step 4: Set Up Notifications (Optional)

Configure notifications for:
- Run completion
- Run failures
- Plan changes

### Step 5: Configure Policies (Optional)

Set up policies for:
- Cost estimation
- Security scanning
- Terraform formatting
- Resource tagging compliance

## Spacelift-Specific Best Practices

### 1. Use Spacelift Contexts

Create contexts for different environments:
- `dev-context`
- `staging-context`
- `prod-context`

### 2. Implement Drift Detection

Enable drift detection to monitor infrastructure changes:
- Set up regular drift detection runs
- Configure alerts for drift detection

### 3. Use Spacelift Workers

Configure workers for:
- Different AWS regions
- Different environments
- Cost optimization

### 4. Implement Approval Workflows

Set up approval workflows for:
- Production deployments
- Costly resource changes
- Security-sensitive modifications

## Code Modifications for Spacelift

### 1. Update main.tf for Better Spacelift Integration

Add Spacelift-specific tags:

```hcl
# Add to all resources
tags = merge(var.tags, {
  ManagedBy = "spacelift"
  SpaceliftStack = var.project_name
})
```

### 2. Create Spacelift-Specific Variables

Add to `variables.tf`:

```hcl
variable "spacelift_stack_id" {
  description = "Spacelift stack ID"
  type        = string
  default     = ""
}

variable "spacelift_run_id" {
  description = "Spacelift run ID"
  type        = string
  default     = ""
}
```

### 3. Enhanced Outputs for Spacelift

Add to `outputs.tf`:

```hcl
output "spacelift_stack_info" {
  description = "Spacelift stack information"
  value = {
    stack_id = var.spacelift_stack_id
    run_id   = var.spacelift_run_id
  }
}
```

## Deployment Process

### 1. Initial Deployment
1. **Plan**: Review the plan in Spacelift UI
2. **Apply**: Deploy the infrastructure
3. **Verify**: Check all resources are created correctly

### 2. Ongoing Management
1. **Monitor**: Use Spacelift dashboard for monitoring
2. **Update**: Make changes through Spacelift
3. **Review**: Use Spacelift's plan review features

## Troubleshooting

### Common Issues:

1. **Authentication Errors**:
   - Verify AWS credentials
   - Check IAM permissions
   - Ensure role assumption is configured correctly

2. **Variable Issues**:
   - Ensure all required variables are set in Spacelift
   - Check variable types and values
   - Verify sensitive variables are marked correctly

3. **Resource Conflicts**:
   - Check for existing resources with same names
   - Use unique project names for different environments
   - Review resource naming conventions

### Support Resources:
- Spacelift Documentation: https://docs.spacelift.io/
- Spacelift Community: https://spacelift.io/community
- AWS Terraform Provider: https://registry.terraform.io/providers/hashicorp/aws

## Security Considerations

1. **Access Control**: Use Spacelift's RBAC features
2. **Secrets Management**: Use Spacelift's secure variable storage
3. **Audit Logging**: Enable comprehensive audit logging
4. **Network Security**: Configure proper network access controls

## Cost Optimization

1. **Resource Tagging**: Implement proper cost allocation tags
2. **Monitoring**: Use Spacelift's cost estimation features
3. **Cleanup**: Set up automated cleanup for unused resources
4. **Scheduling**: Use Spacelift's scheduling features for non-production environments 