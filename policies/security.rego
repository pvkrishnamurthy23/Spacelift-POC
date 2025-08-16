package spacelift

# Security policy for Spacelift
# This policy enforces security best practices

# Deny if security groups allow unrestricted access
deny[sprintf("Security group %v allows unrestricted access", [sg_name])] {
    sg := input.resources[_]
    sg.type == "aws_security_group"
    sg_name := sg.name
    
    # Check for unrestricted ingress rules
    rule := sg.ingress[_]
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port == 22  # SSH
}

# Deny if VPC has public subnets without proper security
deny[sprintf("Public subnet %v without proper security", [subnet_name])] {
    subnet := input.resources[_]
    subnet.type == "aws_subnet"
    subnet_name := subnet.name
    subnet.map_public_ip_on_launch == true
    
    # Check if associated with public route table
    route_table := input.resources[_]
    route_table.type == "aws_route_table"
    route_table.routes[_].gateway_id != ""
}

# Deny if IAM roles have excessive permissions
deny[sprintf("IAM role %v has excessive permissions", [role_name])] {
    role := input.resources[_]
    role.type == "aws_iam_role"
    role_name := role.name
    
    policy := role.policies[_]
    policy.actions[_] == "*"
    policy.resources[_] == "*"
}

# Deny if resources don't have proper tags
deny[sprintf("Resource %v missing required tags", [resource_name])] {
    resource := input.resources[_]
    resource_name := resource.name
    
    not resource.tags.Environment
    not resource.tags.Project
    not resource.tags.ManagedBy
}

# Allow if all security checks pass
allow {
    not has_unrestricted_access
    not has_public_subnets_without_security
    not has_excessive_iam_permissions
    all_resources_properly_tagged
}

has_unrestricted_access {
    sg := input.resources[_]
    sg.type == "aws_security_group"
    rule := sg.ingress[_]
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.from_port == 22
}

has_public_subnets_without_security {
    subnet := input.resources[_]
    subnet.type == "aws_subnet"
    subnet.map_public_ip_on_launch == true
}

has_excessive_iam_permissions {
    role := input.resources[_]
    role.type == "aws_iam_role"
    policy := role.policies[_]
    policy.actions[_] == "*"
    policy.resources[_] == "*"
}

all_resources_properly_tagged {
    resource := input.resources[_]
    resource.tags.Environment
    resource.tags.Project
    resource.tags.ManagedBy
} 