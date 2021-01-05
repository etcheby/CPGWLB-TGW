# CPGWLB-TGW

This template leverages Terraform aws_cloudformation_stack resource to:

* Deploy Check Point ASG for GWLB stack in a new VPC and relevant Subnets (NAT, GWLBe, TGW, Public) based on selected number of AZs; 
* New TGW, TGW Security VPC Attachment; 
* TGW Security RT, Spoke VPC, Subnet and RT, TGW Spoke Attachment and TGW Spoke RT
* Mgmt Server is optional - (if needed use CHECKPOINT MGMT SERVER section in main.tf)

It also deploys:

* 1 TGW, TGW Security VPC attachment, TGW Security RT with association to Security VPC & propagation to Spoke VPC(s)
* 1 Spoke VPC, Subnet, Routes, RT Association 
* Test linux instance with Spoke VPC Attachment to TGW and TGW RT for Spoke(s)

# PS: Using Terraform Cloud as backend - if using local backend, remove the terraform block from provider.tf file

# Private CME package required for Mgmt to auto-discover the Check Point instances behing the GWLB - 

# Solution is currently in EA - Please contact local Check Point Sales Team for Check Point ami to be added to AWS Account, Admin Guide for GWLB CME configuration as well as post deployment steps. 

