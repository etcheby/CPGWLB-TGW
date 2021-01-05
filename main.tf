####################################################
#### CHECK POINT ASG + AWS GWLB + NATGW ############
####################################################

# Deploys new VPC, IGW and relevant Subnets (NAT, GWLBe, TGW, Public) based on selected number of AZs,
# Deploys Check Point ASG, with AWS GWLB, GWLB endpoint service and VPC Endpoint
# Creates GWLB Health Checks and GWLB Target Group
# Creates RT for Public Subnets, NAT GW Subnets, GWLBe subnets & TGW Attachment Subnets.
# A Check Point Mgmt Server (optional) - Please create relevant TF variables for Mgmt parameters 
# PS: You will need to manually create route to spoke VPCs in the created NATGW & GWLBe Subnet RT - See Step 7 of Admin Guide.  

resource "aws_cloudformation_stack" "cpgwlb" {
  name = var.cft_name

  parameters = {

 # VPC CONFIGURATION PARAMETERS - Using 2 AZs only.Please uncomment parameters for AZ3&AZ4 subnet. Enter values in variables.tf

    AvailabilityZones       = var.availability_zones  
    NumberOfAZs             = var.az_number
    VPCCIDR                 = var.gwlbvpc_cidr
    PublicSubnet1CIDR       = var.asg_public1
    PublicSubnet2CIDR       = var.asg_public2
 #  PublicSubnet3CIDR       = var.asg_public3
 #  PublicSubnet4CIDR       = var.asg_public4
    TgwSubnet1CIDR          = var.tgw_subnet1
    TgwSubnet2CIDR          = var.tgw_subnet2
 #  TgwSubnet3CIDR          = var.tgw_subnet3
 #  TgwSubnet4CIDR          = var.tgw_subnet4
    NatGwSubnet1CIDR        = var.natgw_subnet1
    NatGwSubnet2CIDR        = var.natgw_subnet2
 #  NatGwSubnet3CIDR        = var.natgw_subnet3
 #  NatGwSubnet4CIDR        = var.natgw_subnet4
    GWLBeSubnet1CIDR        = var.gwlbe_subnet1
    GWLBeSubnet2CIDR        = var.gwlbe_subnet2
 #  GWLBeSubnet3CIDR        = var.gwlbe_subnet3
 #  GWLBeSubnet4CIDR        = var.gwlbe_subnet4

# GENERAL CHECKPOINT INSTANCE CONFIGURATION
    KeyName                 = var.key_name
    EnableVolumeEncryption  = "false"
    EnableInstanceConnect   = "false"
    AllowUploadDownload     = "true"
    ProvisionTag            = var.provision_tag
    AdminEmail              = ""
    Shell                   = "/bin/bash"

# AWS GWLB CONFIGURATION
    GWLBName                = var.gwlb_name
    TargetGroupName         = var.tg_name
    HealthPort              = var.health_port
    HealthProtocol          = var.health_protocol
    CrossZoneLoadBalancing  = var.crossaz_lb

# CHECKPOINT ASG CONFIGURATION
    GatewayName             = var.gateway_name
    GatewayInstanceType     = var.instance_type
    GatewaysMinSize         = "2"
    GatewaysMaxSize         = "3"
    GatewayVersion          = "R80.40-BYOL"
    GatewayPasswordHash     = var.password_hash
    GatewaySICKey           = var.gateway_sic
    ControlGatewayOverPrivateOrPublicAddress    = var.gateway_control
    CloudWatch              = var.cloudwatch

# CHECKPOINT MGMT SERVER
    ManagementDeploy        = "false"
#   ManagementInstanceType  = ""
#   ManagementVersion       = var.mgmt_version
#   ManagementPasswordHash  = ""
    GatewaysPolicy          = var.gateway_policy
    AdminCIDR               = "0.0.0.0/0"
    GatewayManagement       = var.gateway_management
    GatewaysAddresses       = var.gwlbvpc_cidr

  }

  template_url       = "https://cgi-cfts-staging.s3.amazonaws.com/custom/tgw-gwlb-master.yaml"
  capabilities       = ["CAPABILITY_IAM"]
  disable_rollback   = true
  timeout_in_minutes = 30

}


####################################
###### Internet Gateways  ##########
####################################

resource "aws_internet_gateway" "spoke1_igw" {
  vpc_id = aws_vpc.spoke1_vpc.id 

  tags = {
    Name = "Spoke1-IGW"
  }

}

###################################
##### Spoke-1 VPC & Subnets  ######
###################################


resource "aws_vpc" "spoke1_vpc" {
  cidr_block       = var.spoke1_cidr
  instance_tenancy = "default"

  tags = {
    Name = "Spoke1"
  }
}

resource "aws_subnet" "spoke1_subnet" {
  availability_zone = var.spoke1_subnet_az
  vpc_id            = aws_vpc.spoke1_vpc.id
  cidr_block        = var.spoke1_subnet

  tags = {
    Name = "Spoke1-AZ1"
  }
}

#######################################
#######  Spoke1 Subnet Route Table ####
#######################################

# Spoke1 Subnet RT

resource "aws_route_table" "spoke1_subnet_rt" {
  vpc_id = aws_vpc.spoke1_vpc.id

  # Jump Route from Allowed_Source
  # Comment out if Spoke 1 reacheable privately. No need from a jump route. 
  route {
    cidr_block = "your_whitelisted_pulic_ip"
    gateway_id = aws_internet_gateway.spoke1_igw.id
  }

  # Default Route
  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.gwlb_tgw.id
  }

  tags = {
    Name = "Spoke1-RT"
  }
}

# Spoke1 Subnet RT Association

resource "aws_route_table_association" "spoke1rt_association" {
  subnet_id      = aws_subnet.spoke1_subnet.id 
  route_table_id = aws_route_table.spoke1_subnet_rt.id
}
