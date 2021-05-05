# Code examples for presentation "Introduction to infrastructure as code in Terraform"

## Requirements
- Terraform installed/available in system,
- AWS CLI installed/available in system,
- AWS account created and set up – credentials for CLI must be created 
and either added to configuration in home directory or to environment variables.
  


## Examples
All examples are simple and standalone, and can be described as follows:
- 1.1. – "hello world" with single EC2,
- 1.2. – multiple EC2 instances created with count,
- 1.3. – single EC2 instance with HTTP server, 
- 2.1. – simple example of using remote backend,
- 3.1. – single endpoint (integrated with Lambda) application returning random 
cat pictures,
  
All of them, other than AWS account configured have no external dependencies and can be
deployed by simple combination of basic terraform commands.
```
terraform init 
terraform apply
```

(`terraform destroy` can be used later for clean up)