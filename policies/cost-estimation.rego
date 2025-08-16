package spacelift

# Cost estimation policy for Spacelift
# This policy helps control infrastructure costs

# Deny if estimated monthly cost exceeds threshold
deny[sprintf("Estimated monthly cost $%v exceeds budget limit of $%v", [cost, limit])] {
    cost := input.cost_estimation.monthly_cost
    limit := 100  # Set your budget limit here
    cost > limit
}

# Deny if any resource type is expensive
deny[sprintf("Expensive resource type detected: %v", [resource_type])] {
    resource_type := input.resources[_].type
    expensive_types := {"aws_instance", "aws_lb", "aws_nat_gateway", "aws_rds_instance"}
    expensive_types[resource_type]
    input.resources[_].type == resource_type
    input.resources[_].estimated_cost > 50  # $50 threshold per resource
}

# Allow if cost is within budget
allow {
    input.cost_estimation.monthly_cost <= 100
    not contains_expensive_resources
}

contains_expensive_resources {
    resource := input.resources[_]
    resource.estimated_cost > 50
} 