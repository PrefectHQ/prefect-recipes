# Prefect ECS Deployment Cloudformation Templates

AWS Cloudformation templates to deploy a Prefect 1.0 Server and Agent on Elastic Container Service (ECS)  


## Requirements: 

**Prefect Agent:**
    -- A VPC
    -- ARN of IAM ecsTaskExecutionRole 
    -- Prefect API URL IF using Server Backend
    -- Prefect Cloud API Key IF using Cloud Backend
    -- **Useful**
        -- Custom Prefect Task Execution Role


**Prefect Server:** 
    -- A VPC
    -- ARN of Application Load Balancer
    -- ARN of TargetGroup on ALB that handles Port 443
    -- ARN of SSL Certificates
    -- ARN IAM ecsTaskExecutionRole or Custom Task Execution Role 
    -- DB Connection String to Existing Postgres DB
    -- Prefect Domain Name
    -- **Useful**
        -- ALB Listener To Redirect Traffic from Port 443 to Internet Accessible Security Group 
        -- ALB Listeners to Forward Traffic from Port 4200 to Fixed Response 503




