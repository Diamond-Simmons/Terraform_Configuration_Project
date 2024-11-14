# Terraform AWS Infrastructure Setup

This Terraform configuration creates a basic AWS infrastructure with a Virtual Private Cloud (VPC), subnets, an internet gateway, a NAT gateway, route tables, and two EC2 instances (one in a public subnet and one in a private subnet).

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) installed on your machine
- AWS account and AWS credentials configured
- Key pair for SSH access to the public EC2 instance

## Resources

This configuration creates the following resources in the AWS `us-west-2` region:

1. **VPC**: A Virtual Private Cloud with a CIDR block of `10.0.0.0/16`.
2. **Subnets**:
   - Public Subnet: `10.0.1.0/24` for the public EC2 instance, NAT gateway, and internet gateway connection.(availability zone us-west-2a)
   - Private Subnet: `10.0.2.0/24` for the private EC2 instance. (availability zone us-west-2b)
3. **Internet Gateway**: Enables internet access for the public subnet.
4. **NAT Gateway**: Allows outbound internet access for resources in the private subnet.
5. **Elastic IP**: Allocates an IP address for the NAT Gateway.
6. **Route Tables**:
   - Public Route Table: Routes internet-bound traffic via the internet gateway.
   - Private Route Table: Routes traffic via the NAT gateway for internet access.
7. **EC2 Instances**:
   - Public EC2 instance: Accessible via SSH in the public subnet. (use your created key pair to access)
   - Private EC2 instance: Accessible only within the private subnet.
8. **Security Groups**:
   - Default security group for the public EC2 instance.
   - Custom security group for the private EC2 instance to allow internal access and outbound traffic to the NAT gateway.

