// FGTVM instance AZ2

resource "aws_network_interface" "fgt3eth0" {
  count       = local.config.firewall_az2c ? 1 : 0
  description = "fgtvm3-port1"
  subnet_id   = aws_subnet.publicsubnet["public_az2c"].id
}

resource "aws_network_interface" "fgt3eth1" {
  count             = local.config.firewall_az2c ? 1 : 0
  description       = "fgtvm3-port2"
  subnet_id         = aws_subnet.privatesubnet["private_az2c"].id
  source_dest_check = false
}

data "aws_network_interface" "fgt3eth1" {
  count = local.config.firewall_az2c ? 1 : 0
  id    = aws_network_interface.fgt3eth1[count.index].id
}

//
data "aws_network_interface" "vpcendpointipaz2c_fgt3" {
  count      = local.config.firewall_az2c ? 1 : 0
  depends_on = [aws_vpc_endpoint.gwlbendpoints["az2c"]]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.fgtvm-vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  //  Using AZ1's endpoint ip
  filter {
    name   = "availability-zone"
    values = ["${local.config.az3}"]
  }
}

data "aws_network_interface" "vpcendpointipaz2a_fgt3" {
  count      = local.config.firewall_az2c ? 1 : 0
  depends_on = [aws_vpc_endpoint.gwlbendpoints["az2c"]]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.fgtvm-vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  //  Using AZ1's endpoint ip
  filter {
    name   = "availability-zone"
    values = ["${local.config.az1}"]
  }
}

data "aws_network_interface" "vpcendpointipaz2b_fgt3" {
  count      = local.config.firewall_az2c ? 1 : 0
  depends_on = [aws_vpc_endpoint.gwlbendpoints["az2c"]]
  filter {
    name   = "vpc-id"
    values = ["${aws_vpc.fgtvm-vpc.id}"]
  }
  filter {
    name   = "status"
    values = ["in-use"]
  }
  filter {
    name   = "description"
    values = ["*ELB*"]
  }
  //  Using AZ1's endpoint ip
  filter {
    name   = "availability-zone"
    values = ["${local.config.az2}"]
  }
}

resource "aws_network_interface_sg_attachment" "fgt3publicattachment" {
  count                = local.config.firewall_az2c ? 1 : 0
  depends_on           = [aws_network_interface.fgt3eth0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.fgt3eth0[count.index].id
}

resource "aws_network_interface_sg_attachment" "fgt3internalattachment" {
  count                = local.config.firewall_az2c ? 1 : 0
  depends_on           = [aws_network_interface.fgt3eth1]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.fgt3eth1[count.index].id
}


resource "aws_instance" "fgtvm3" {
  count             = local.config.firewall_az2c ? 1 : 0
  ami               = local.config.license_type == "byol" ? var.fgtvmbyolami[local.config.region] : var.fgtvmami[local.config.region]
  instance_type     = local.config.size
  availability_zone = local.config.az3
  key_name          = local.config.keyname
  user_data         = data.template_file.FortiGate3[count.index].rendered

  root_block_device {
    volume_type = "standard"
    volume_size = "2"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.fgt3eth0[count.index].id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fgt3eth1[count.index].id
    device_index         = 1
  }

  tags = {
    Name = "FortiGateVM3"
  }
}


data "template_file" "FortiGate3" {
  count    = local.config.firewall_az2c ? 1 : 0
  template = file("${local.config.bootstrap-fgtvm3}")
  vars = {
    type         = "${local.config.license_type}"
    license_file = "${local.config.license3}"
    adminsport   = "${local.config.adminsport}"
    cidr         = "${local.config.vpccidr}"
    gateway      = cidrhost(local.settings_pvt.private_az2c.subnet, 1)
    endpointip   = "${data.aws_network_interface.vpcendpointipaz2c_fgt3[count.index].private_ip}"
    endpointip2a = "${data.aws_network_interface.vpcendpointipaz2a_fgt3[count.index].private_ip}"
    endpointip2b = "${data.aws_network_interface.vpcendpointipaz2b_fgt3[count.index].private_ip}"
  }
}

