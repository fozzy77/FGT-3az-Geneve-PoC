
locals {

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
    "csprivate_az2a" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 0), az = local.config.az1 }
    "csprivate_az2b" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 1), az = local.config.az2 }
    "csprivate_az2c" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 2), az = local.config.az3 }
  }

  settings_csendpoint = {
    "csendpoint_az2a" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 3), az = local.config.az1 }
    "csendpoint_az2b" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 4), az = local.config.az2 }
    "csendpoint_az2c" = { subnet = cidrsubnet(local.config.csvpccidr, 5, 5), az = local.config.az3 }
  }
  common_tags = {
    Terraform   = true
    Environment = "Production_${aws_vpc.customer-vpc.id}"
  }
}

#### AWS VPC - FortiGate
resource "aws_vpc" "fgtvm-vpc" {
  cidr_block           = local.config.vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  instance_tenancy     = "default"
  tags = {
    Name = "security vpc"
  }
}

resource "aws_subnet" "publicsubnet" {
  for_each          = local.settings
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = {
    Name = "publicsubnet_${aws_vpc.customer-vpc.id}_${each.value.az}"
  }
}

resource "aws_subnet" "privatesubnet" {
  for_each          = local.settings_pvt
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = {
    Name = "privatesubnet_${aws_vpc.customer-vpc.id}_${each.value.az}"
  }
}

resource "aws_subnet" "transitsubnet" {
  for_each          = local.settings_trn
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = {
    Name = "transitsubnet_${aws_vpc.customer-vpc.id}_${each.value.az}"
  }
}

resource "aws_subnet" "gwlbsubnet" {
  for_each          = local.settings_gwlb
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = {
    Name = "gwlbsubnet_${aws_vpc.customer-vpc.id}_${each.value.az}"
  }
}

##### AWS VPC - Customer
resource "aws_vpc" "customer-vpc" {
  cidr_block           = local.config.csvpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = false
  instance_tenancy     = "default"
  tags = {
    Name = "customer vpc"
  }
}

resource "aws_subnet" "csprivatesubnet" {
  for_each          = local.settings_csprivate
  vpc_id            = aws_vpc.customer-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = merge(
    local.common_tags,
    {
      Name = "privatesubnet_${aws_vpc.customer-vpc.id}_${each.value.az}"
    },
  )
}

resource "aws_subnet" "csendpointsubnet" {
  for_each          = local.settings_csendpoint
  vpc_id            = aws_vpc.customer-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = merge(
    local.common_tags,
    {
      Name = "endpointsubnet_${aws_vpc.customer-vpc.id}_${each.value.az}"
    },
  )
}
