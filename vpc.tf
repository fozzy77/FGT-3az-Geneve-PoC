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
    Name = "publicsubnet_${each.value.subnet}_${each.value.az}"
  }
}

resource "aws_subnet" "privatesubnet" {
  for_each          = local.settings_pvt
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = {
    Name = "privatesubnet_${each.value.subnet}_${each.value.az}"
  }
}

resource "aws_subnet" "transitsubnet" {
  for_each          = local.settings_trn
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = {
    Name = "transitsubnet_${each.value.subnet}_${each.value.az}"
  }
}

resource "aws_subnet" "gwlbsubnet" {
  for_each          = local.settings_gwlb
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = each.value.subnet
  availability_zone = each.value.az
  tags = {
    Name = "gwlb_${each.value.subnet}_${each.value.az}"
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
      Name = "privatesubnet_${each.value.subnet}_${each.value.az}"
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
      Name = "endpointsubnet_${each.value.subnet}_${each.value.az}"
    },
  )
}
