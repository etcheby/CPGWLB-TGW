# CPGWLB-TGW

This template leverages Terraform aws_cloudformation_stack resource to:

* Deploy Check Point ASG for GWLB stack with VPC, IGW and relevant Subnets (NAT, GWLBe, TGW, Public) based on selected number of AZs; 
* New TGW, TGW Security VPC Attachment; 
* TGW Security RT, Spoke VPC, Subnet and RT, TGW Spoke Attachment and TGW Spoke RT
* Mgmt Server is optional - 

It also deploys:

* TGW, TGW Security VPC attachment, TGW Security RT with association & propagation
* Spoke 1 VPC, Subnet, RT and test linux instance with Spoke VPC Attachment to TGW and TGW RT for Spoke(s)

# PS: Using Terraform Cloud as backend - if using local backend, remove the terraform block from provider.tf file

