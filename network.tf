// Creating Internet Gateway
resource "aws_internet_gateway" "fgtvmigw" {
  vpc_id = aws_vpc.fgtvm-vpc.id
  tags = {
    Name = "fgtvm-igw"
  }
}

// FGT VPC Route Table FGT2a
resource "aws_route_table" "fgtvmpublicrt2a" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-NATGW-az2a"
  }
}
resource "aws_route_table" "fgtvmprivatert2a" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-DATA-az2a"
  }
}
resource "aws_route_table" "fgtvmtgwrt2a" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-TGW-az2a"
  }
}
resource "aws_route_table" "fgtvmgwlbrt2a" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-GWLBe-az2a"
  }
}




// FGT VPC Route Tables FGT2b
resource "aws_route_table" "fgtvmpublicrt2b" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-NATGW-az2b"
  }
}
resource "aws_route_table" "fgtvmprivatert2b" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-DATA-az2b"
  }
}
resource "aws_route_table" "fgtvmtgwrt2b" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-TGW-az2b"
  }
}
resource "aws_route_table" "fgtvmgwlbrt2b" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-GWLBe-az2b"
  }
}


// FGT VPC Route Tables FGT2a
resource "aws_route_table" "fgtvmpublicrt2c" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-NATGW-az2c"
  }
}
resource "aws_route_table" "fgtvmprivatert2c" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-DATA-az2c"
  }
}
resource "aws_route_table" "fgtvmtgwrt2c" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-TGW-az2c"
  }
}
resource "aws_route_table" "fgtvmgwlbrt2c" {
  vpc_id = aws_vpc.fgtvm-vpc.id

  tags = {
    Name = "Sec-GWLBe-az2c"
  }
}

#### CS VPC Route Tables
resource "aws_route_table" "cs_private" {
  vpc_id = aws_vpc.customer-vpc.id

  tags = {
    Name = "private-route"
  }
}

resource "aws_route" "cs_private" {
  route_table_id         = aws_route_table.cs_private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.terraform-tgwy.id
}

#### FGT Route Tables Associations CSprivate to reduce iteration
resource "aws_route_table_association" "csprivate_association" {
  for_each       = local.settings_csprivate
  subnet_id      = aws_subnet.csprivatesubnet[each.key].id
  route_table_id = each.value.rt
}

#### FGT VPC Specific Routes per route table
resource "aws_route" "externalroute" {
  route_table_id         = aws_route_table.fgtvmpublicrt2a.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fgtvmigw.id
}

resource "aws_route" "externalroutetovpc1" {
  depends_on             = [aws_vpc_endpoint.gwlbendpointaz2a]
  route_table_id         = aws_route_table.fgtvmpublicrt2a.id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpointaz2a.id
}

resource "aws_route" "tgwyroute" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fgtvmtgwrt2a.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpointaz2a.id
}

resource "aws_route" "gwlbroutecs" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fgtvmgwlbrt2a.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.terraform-tgwy.id
}


#### NAT AZ 2a
resource "aws_eip" "nat_gateway_az2a" {
  vpc = true
}

resource "aws_nat_gateway" "az2a" {
  allocation_id = aws_eip.nat_gateway_az2a.id
  subnet_id     = aws_subnet.publicsubnet["public_az2a"].id

  tags = {
    Name = "gw NAT az2a"
  }
}
resource "aws_route" "gwlbroute2a-nat" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fgtvmgwlbrt2a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az2a.id
}



#### FGT VPC Route 2b
resource "aws_route" "externalroute2b" {
  route_table_id         = aws_route_table.fgtvmpublicrt2b.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fgtvmigw.id
}

resource "aws_route" "externalroutetovpc2b" {
  depends_on             = [aws_vpc_endpoint.gwlbendpointaz2b]
  route_table_id         = aws_route_table.fgtvmpublicrt2b.id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpointaz2b.id
}

resource "aws_route" "tgwyroute2b" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fgtvmtgwrt2b.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpointaz2b.id
}

resource "aws_route" "gwlbroute2b" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fgtvmgwlbrt2b.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.terraform-tgwy.id
}

#### NAT AZ 2b
resource "aws_eip" "nat_gateway_az2b" {
  /*   count = local.config.firewall_az2b ? 1 : 0 */
  vpc = true
}

resource "aws_nat_gateway" "az2b" {
  /*   count = local.config.firewall_az2b ? 1 : 0 */
  # allocation_id = aws_eip.nat_gateway_az2b[0].id
  allocation_id = aws_eip.nat_gateway_az2b.id
  subnet_id     = aws_subnet.publicsubnet["public_az2b"].id

  tags = {
    Name = "gw NAT az2b"
  }
}
resource "aws_route" "gwlbroute2b-nat" {
  /*   count = local.config.firewall_az2b ? 1 : 0 */
  route_table_id         = aws_route_table.fgtvmgwlbrt2b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az2b.id
  # nat_gateway_id         = aws_nat_gateway.az2b[0].id
}

#### FGT VPC Route 2c
resource "aws_route" "externalroute2c" {
  route_table_id         = aws_route_table.fgtvmpublicrt2c.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fgtvmigw.id
}

resource "aws_route" "externalroutetovpc12c" {
  depends_on             = [aws_vpc_endpoint.gwlbendpointaz2c]
  route_table_id         = aws_route_table.fgtvmpublicrt2c.id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpointaz2c.id
}

resource "aws_route" "tgwyroute2c" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fgtvmtgwrt2c.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.gwlbendpointaz2c.id
}

resource "aws_route" "gwlbroute2c" {
  depends_on             = [aws_instance.fgtvm]
  route_table_id         = aws_route_table.fgtvmgwlbrt2c.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.terraform-tgwy.id
}

#### NAT AZ 2c
resource "aws_eip" "nat_gateway_az2c" {
  /*   count      = local.config.firewall_az2c ? 1 : 0 */
  vpc = true
}
resource "aws_nat_gateway" "az2c" {
  /*   count      = local.config.firewall_az2c ? 1 : 0 */
  # allocation_id = aws_eip.nat_gateway_az2c[0].id
  allocation_id = aws_eip.nat_gateway_az2c.id
  subnet_id     = aws_subnet.publicsubnet["public_az2c"].id

  tags = {
    Name = "gw NAT az2c"
  }
}
resource "aws_route" "gwlbroute2c-nat" {
  /*   count      = local.config.firewall_az2c ? 1 : 0 */
  route_table_id         = aws_route_table.fgtvmgwlbrt2c.id
  destination_cidr_block = "0.0.0.0/0"
  # nat_gateway_id         = aws_nat_gateway.az2c[0].id
  nat_gateway_id = aws_nat_gateway.az2c.id
}

#### FGT Route Tables Associations TGW to reduce iteration
resource "aws_route_table_association" "fgttgwsubnet_association" {
  for_each       = local.settings_trn
  subnet_id      = aws_subnet.transitsubnet[each.key].id
  route_table_id = each.value.rt
}

#### FGT Route Tables Associations GWLBe to reduce iteration
resource "aws_route_table_association" "fgtgwlbsubnet_association" {
  for_each       = local.settings_gwlb
  subnet_id      = aws_subnet.gwlbsubnet[each.key].id
  route_table_id = each.value.rt
}

#### FGT Route Tables Associations Public to reduce iteration
resource "aws_route_table_association" "fgtpublicsubnet_association" {
  for_each       = local.settings
  subnet_id      = aws_subnet.publicsubnet[each.key].id
  route_table_id = each.value.rt
}

#### FGT Route Tables Associations Private to reduce iteration
resource "aws_route_table_association" "privatesubnet_association" {
  for_each       = local.settings_pvt
  subnet_id      = aws_subnet.privatesubnet[each.key].id
  route_table_id = each.value.rt
}

#### FGT EIPs
resource "aws_eip" "FGTPublicIP" {
  depends_on        = [aws_instance.fgtvm]
  vpc               = true
  network_interface = aws_network_interface.eth0.id
}

resource "aws_eip" "FGT2PublicIP" {
  count             = local.config.firewall_az2b ? 1 : 0
  depends_on        = [aws_instance.fgtvm2]
  vpc               = true
  network_interface = aws_network_interface.fgt2eth0[count.index].id
}

resource "aws_eip" "FGT3PublicIP" {
  count             = local.config.firewall_az2c ? 1 : 0
  depends_on        = [aws_instance.fgtvm3]
  vpc               = true
  network_interface = aws_network_interface.fgt3eth0[count.index].id
}


#### Security Group for the public facing interface on the fortinets
resource "aws_security_group" "public_allow" {
  name        = "Public Allow"
  description = "Public Allow traffic"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public Allow"
  }
}

#### Security Group for the private facing interface on the fortinets
resource "aws_security_group" "allow_all" {
  name        = "Private Allow All"
  description = "Private Allow all traffic"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private Allow"
  }
}

####  Gateway Load Balancer on FGT VPC to multiple FGTs
resource "aws_lb" "gateway_lb" {
  name                             = "gatewaylb"
  load_balancer_type               = "gateway"
  enable_cross_zone_load_balancing = true

  // AZ1
  subnet_mapping {
    subnet_id = aws_subnet.privatesubnet["private_az2a"].id
  }
  // AZ2
  subnet_mapping {
    subnet_id = aws_subnet.privatesubnet["private_az2b"].id
  }
  // AZ2
  subnet_mapping {
    subnet_id = aws_subnet.privatesubnet["private_az2c"].id
  }
}

resource "aws_lb_target_group" "fgt_target" {
  name        = "fgttarget"
  port        = 6081
  protocol    = "GENEVE"
  target_type = "ip"
  vpc_id      = aws_vpc.fgtvm-vpc.id

  health_check {
    port     = 8008
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "fgt_listener" {
  load_balancer_arn = aws_lb.gateway_lb.id

  default_action {
    target_group_arn = aws_lb_target_group.fgt_target.id
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "fgtattach" {
  depends_on       = [aws_instance.fgtvm]
  target_group_arn = aws_lb_target_group.fgt_target.arn
  target_id        = data.aws_network_interface.eth1.private_ip
  port             = 6081
}

resource "aws_lb_target_group_attachment" "fgt2attach" {
  count            = local.config.firewall_az2b ? 1 : 0
  depends_on       = [aws_instance.fgtvm2]
  target_group_arn = aws_lb_target_group.fgt_target.arn
  target_id        = data.aws_network_interface.fgt2eth1[count.index].private_ip
  port             = 6081
}

resource "aws_lb_target_group_attachment" "fgt3attach" {
  count            = local.config.firewall_az2c ? 1 : 0
  depends_on       = [aws_instance.fgtvm3]
  target_group_arn = aws_lb_target_group.fgt_target.arn
  target_id        = data.aws_network_interface.fgt3eth1[count.index].private_ip
  port             = 6081
}


resource "aws_vpc_endpoint_service" "fgtgwlbservice" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gateway_lb.arn]
}

#### FGT Endpoints per AZ
resource "aws_vpc_endpoint" "gwlbendpointaz2a" {
  service_name      = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  subnet_ids        = [aws_subnet.gwlbsubnet["gwlb_az2a"].id]
  vpc_endpoint_type = aws_vpc_endpoint_service.fgtgwlbservice.service_type
  vpc_id            = aws_vpc.fgtvm-vpc.id
}

resource "aws_vpc_endpoint" "gwlbendpointaz2b" {
  service_name      = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  subnet_ids        = [aws_subnet.gwlbsubnet["gwlb_az2b"].id]
  vpc_endpoint_type = aws_vpc_endpoint_service.fgtgwlbservice.service_type
  vpc_id            = aws_vpc.fgtvm-vpc.id
}

resource "aws_vpc_endpoint" "gwlbendpointaz2c" {
  service_name      = aws_vpc_endpoint_service.fgtgwlbservice.service_name
  subnet_ids        = [aws_subnet.gwlbsubnet["gwlb_az2c"].id]
  vpc_endpoint_type = aws_vpc_endpoint_service.fgtgwlbservice.service_type
  vpc_id            = aws_vpc.fgtvm-vpc.id
}

#### CS Endpoint Security Group
resource "aws_security_group" "sg1" {
  name        = "Allow All"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.customer-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Name = "Private Allow"
  }
}


#### Creation of the SSM Endpoints to allow access to the Test EC2 instance over SSM

resource "aws_vpc_endpoint" "endpoints" {
  for_each          = local.endpoints
  service_name      = each.value.service
  subnet_ids        = [aws_subnet.csprivatesubnet["csprivate_az2a"].id]
  vpc_endpoint_type = each.value.type
  vpc_id            = aws_vpc.customer-vpc.id
  security_group_ids = [
    each.value.sg,
  ]

  private_dns_enabled = true
}