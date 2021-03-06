#####################################
######### Transit GW  ###############
#####################################

# Create the TGW
resource "aws_ec2_transit_gateway" "gwlb_tgw" {
  description                     = "TGW to demo Check Point Integration with GWLB"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "GWLB-TGW"
  }
}


#################################
#######  TGW Attachments ########
#################################

# Create Security VPC TGW Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "security_attachment" {
  subnet_ids                                      = [aws_cloudformation_stack.cpgwlb.outputs["TgwSubnet1ID"],aws_cloudformation_stack.cpgwlb.outputs["TgwSubnet2ID"]]
  transit_gateway_id                              = aws_ec2_transit_gateway.gwlb_tgw.id
  vpc_id                                          = aws_cloudformation_stack.cpgwlb.outputs["VPCID"]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "Security"
  }
}

# Create Spoke1 VPC TGW Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke1_vpc_attachment" {
  subnet_ids                                      = [aws_subnet.spoke1_subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.gwlb_tgw.id
  vpc_id                                          = aws_vpc.spoke1_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    Name = "Spoke1"
  }
}

#####################################
######## TGW - Security RT  #########
#####################################

# Create a Security TGW RT

resource "aws_ec2_transit_gateway_route_table" "tgwrt_security" {
  transit_gateway_id = aws_ec2_transit_gateway.gwlb_tgw.id
  tags = {
    Name = "Security"
  }
}

# Associate the Security VPC attachment to this TGW RT

resource "aws_ec2_transit_gateway_route_table_association" "tgw_security_attachment_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.security_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_security.id
}


# Propagate Spokes VPC Attachment Routes Into TGW Security Attachment

resource "aws_ec2_transit_gateway_route_table_propagation" "tgwrt_security_spoke1_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke1_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_security.id
}


#####################################
######## TGW - Spokes RT    #########
#####################################

# Create Spokes TGW RT

resource "aws_ec2_transit_gateway_route_table" "tgwrt_spokes" {
  transit_gateway_id = aws_ec2_transit_gateway.gwlb_tgw.id
  tags = {
    Name = "Spokes"
  }
}

# Associate Spoke1 VPC attachment to this TGW Spokes RT

resource "aws_ec2_transit_gateway_route_table_association" "tgwrt_spoke1_attachement_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke1_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_spokes.id
}

# Propagate Security VPC Routes Into TGW Spokes RT

resource "aws_ec2_transit_gateway_route_table_propagation" "tgwrt_spokes_security_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.security_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_spokes.id
}