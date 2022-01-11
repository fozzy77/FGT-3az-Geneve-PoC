########################################################
# Transit Gateway
########################################################
resource "aws_ec2_transit_gateway" "terraform-tgwy" {
  description                     = "Transit Gateway with 2 VPCs"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "terraform-tgwy"
  }
  lifecycle {
    ignore_changes = all
  }
}

/* # Route Table - FGT VPC
resource "aws_ec2_transit_gateway_route_table" "tgwy-fgt-route" {
  depends_on         = [aws_ec2_transit_gateway.terraform-tgwy]
  transit_gateway_id = aws_ec2_transit_gateway.terraform-tgwy.id
  tags = {
    Name = "tgwy-fgt-route"
  }
} */

# Route Table - Live Services
resource "aws_ec2_transit_gateway_route_table" "tgwy-vpc-route" {
  depends_on         = [aws_ec2_transit_gateway.terraform-tgwy]
  transit_gateway_id = aws_ec2_transit_gateway.terraform-tgwy.id
  tags = {
    Name = "tgwy-customer-vpc-route"
  }
}


# VPC attachment - FGT VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-fgt" {
  appliance_mode_support                          = "enable"
  subnet_ids                                      = [aws_subnet.transitsubnet["attach_az2a"].id, aws_subnet.transitsubnet["attach_az2b"].id, aws_subnet.transitsubnet["attach_az2c"].id]
  transit_gateway_id                              = aws_ec2_transit_gateway.terraform-tgwy.id
  vpc_id                                          = aws_vpc.fgtvm-vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "tgwy-fgt-attachment"
  }
  depends_on = [aws_ec2_transit_gateway.terraform-tgwy]
}


# VPC attachment - CS1 VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-vpc1" {
  appliance_mode_support                          = "enable"
  subnet_ids                                      = [aws_subnet.csendpointsubnet["csendpoint_az2a"].id, aws_subnet.csendpointsubnet["csendpoint_az2b"].id, aws_subnet.csendpointsubnet["csendpoint_az2c"].id]
  transit_gateway_id                              = aws_ec2_transit_gateway.terraform-tgwy.id
  vpc_id                                          = aws_vpc.customer-vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name = "tgwy-vpc1-attachment"
  }
  depends_on = [aws_ec2_transit_gateway.terraform-tgwy]
}


# TGW Routes - Customer VPC
resource "aws_ec2_transit_gateway_route" "customer-default-route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-fgt.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwy-vpc-route.id
}

# Route Tables Associations - Customer VPC
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-customer-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwy-vpc-route.id
}

# Route Tables Associations - FGT VPC
resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-fgt-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-fgt.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwy-vpc-route.id
}


# Route Tables Propagations - FGT VPC Route
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prop-fgt-w-cs" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwy-vpc-route.id
}



