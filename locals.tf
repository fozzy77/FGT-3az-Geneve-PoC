locals {
  config = var.env_config[terraform.workspace]

  settings = {
    "public_az2a" = { subnet = cidrsubnet(local.config.vpccidr, 5, 0), az = local.config.az1, rt = aws_route_table.fgtvmpublicrt2a.id }
    "public_az2b" = { subnet = cidrsubnet(local.config.vpccidr, 5, 1), az = local.config.az2, rt = aws_route_table.fgtvmpublicrt2b.id }
    "public_az2c" = { subnet = cidrsubnet(local.config.vpccidr, 5, 2), az = local.config.az3, rt = aws_route_table.fgtvmpublicrt2c.id }
  }

  settings_pvt = {
    "private_az2a" = { subnet = cidrsubnet(local.config.vpccidr, 5, 3), az = local.config.az1, rt = aws_route_table.fgtvmprivatert2a.id }
    "private_az2b" = { subnet = cidrsubnet(local.config.vpccidr, 5, 4), az = local.config.az2, rt = aws_route_table.fgtvmprivatert2b.id }
    "private_az2c" = { subnet = cidrsubnet(local.config.vpccidr, 5, 5), az = local.config.az3, rt = aws_route_table.fgtvmprivatert2c.id }
  }

  settings_trn = {
    "attach_az2a" = { subnet = cidrsubnet(local.config.vpccidr, 5, 6), az = local.config.az1, rt = aws_route_table.fgtvmtgwrt2a.id }
    "attach_az2b" = { subnet = cidrsubnet(local.config.vpccidr, 5, 7), az = local.config.az2, rt = aws_route_table.fgtvmtgwrt2b.id }
    "attach_az2c" = { subnet = cidrsubnet(local.config.vpccidr, 5, 8), az = local.config.az3, rt = aws_route_table.fgtvmtgwrt2c.id }
  }

  settings_gwlb = {
    "gwlb_az2a" = { subnet = cidrsubnet(local.config.vpccidr, 5, 9), az = local.config.az1, rt = aws_route_table.fgtvmgwlbrt2a.id }
    "gwlb_az2b" = { subnet = cidrsubnet(local.config.vpccidr, 5, 10), az = local.config.az2, rt = aws_route_table.fgtvmgwlbrt2b.id }
    "gwlb_az2c" = { subnet = cidrsubnet(local.config.vpccidr, 5, 11), az = local.config.az3, rt = aws_route_table.fgtvmgwlbrt2c.id }
  }

  settings_csprivate = {
    "csprivate_az2a" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 0), az = local.config.az1, rt = aws_route_table.cs_private.id }
    "csprivate_az2b" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 1), az = local.config.az2, rt = aws_route_table.cs_private.id }
    "csprivate_az2c" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 2), az = local.config.az3, rt = aws_route_table.cs_private.id }
  }

  settings_csendpoint = {
    "csendpoint_az2a" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 3), az = local.config.az1 }
    "csendpoint_az2b" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 4), az = local.config.az2 }
    "csendpoint_az2c" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 5), az = local.config.az3 }
  }
  common_tags = {
    Terraform = true
  }
  endpoints = {
    "ssm"          = { service = "com.amazonaws.eu-west-2.ssm", sg = aws_security_group.sg1.id, type = "Interface" }
    "ssmmessages"  = { service = "com.amazonaws.eu-west-2.ssmmessages", sg = aws_security_group.sg1.id, type = "Interface" }
    "ec2mmessages" = { service = "com.amazonaws.eu-west-2.ec2messages", sg = aws_security_group.sg1.id, type = "Interface" }
  }
  gwlbendpoints = {
    "az2a" = { service = aws_vpc_endpoint_service.fgtgwlbservice.service_name, subnet = aws_subnet.csprivatesubnet["csprivate_az2a"].id, type = aws_vpc_endpoint_service.fgtgwlbservice.service_type }
    "az2b" = { service = aws_vpc_endpoint_service.fgtgwlbservice.service_name, subnet = aws_subnet.csprivatesubnet["csprivate_az2b"].id, type = aws_vpc_endpoint_service.fgtgwlbservice.service_type }
    "az2c" = { service = aws_vpc_endpoint_service.fgtgwlbservice.service_name, subnet = aws_subnet.csprivatesubnet["csprivate_az2c"].id, type = aws_vpc_endpoint_service.fgtgwlbservice.service_type }
  }
}