// FGTVM instance AZ2

resource "aws_network_interface" "fgt2eth0" {
  count       = local.config.firewall_az2b ? 1 : 0
  description = "fgtvm2-port1"
  subnet_id   = aws_subnet.publicsubnet["public_az2b"].id
}

resource "aws_network_interface" "fgt2eth1" {
  count             = local.config.firewall_az2b ? 1 : 0
  description       = "fgtvm2-port2"
  subnet_id         = aws_subnet.privatesubnet["private_az2b"].id
  source_dest_check = false
}

data "aws_network_interface" "fgt2eth1" {
  count = local.config.firewall_az2b ? 1 : 0
  id    = aws_network_interface.fgt2eth1[count.index].id
}

//
data "aws_network_interface" "vpcendpointipaz2b_fgt2" {
  count      = local.config.firewall_az2b ? 1 : 0
  depends_on = [aws_vpc_endpoint.gwlbendpointaz2b]
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

data "aws_network_interface" "vpcendpointipaz2a_fgt2" {
  count      = local.config.firewall_az2b ? 1 : 0
  depends_on = [aws_vpc_endpoint.gwlbendpointaz2b]
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

data "aws_network_interface" "vpcendpointipaz2c_fgt2" {
  count      = local.config.firewall_az2b ? 1 : 0
  depends_on = [aws_vpc_endpoint.gwlbendpointaz2a]
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

resource "aws_network_interface_sg_attachment" "fgt2publicattachment" {
  count                = local.config.firewall_az2b ? 1 : 0
  depends_on           = [aws_network_interface.fgt2eth0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.fgt2eth0[count.index].id
}

resource "aws_network_interface_sg_attachment" "fgt2internalattachment" {
  count                = local.config.firewall_az2b ? 1 : 0
  depends_on           = [aws_network_interface.fgt2eth1]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.fgt2eth1[count.index].id
}


resource "aws_instance" "fgtvm2" {
  count             = local.config.firewall_az2b ? 1 : 0
  ami               = local.config.license_type == "byol" ? var.fgtvmbyolami[local.config.region] : var.fgtvmami[local.config.region]
  instance_type     = local.config.size
  availability_zone = local.config.az2
  key_name          = local.config.keyname
  user_data         = data.template_file.FortiGate2[count.index].rendered

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
    network_interface_id = aws_network_interface.fgt2eth0[count.index].id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.fgt2eth1[count.index].id
    device_index         = 1
  }

  tags = {
    Name = "FortiGateVM2"
  }
}


data "template_file" "FortiGate2" {
  count    = local.config.firewall_az2b ? 1 : 0
  template = file("${local.config.bootstrap-fgtvm2}")
  vars = {
    type         = "${local.config.license_type}"
    license_file = "${local.config.license2}"
    adminsport   = "${local.config.adminsport}"
    cidr         = "${local.config.vpccidr}"
    gateway      = cidrhost(local.settings_pvt.private_az2b.subnet, 1)
    endpointip   = "${data.aws_network_interface.vpcendpointipaz2b_fgt2[count.index].private_ip}"
    endpointip2a = "${data.aws_network_interface.vpcendpointipaz2a_fgt2[count.index].private_ip}"
    endpointip2c = "${data.aws_network_interface.vpcendpointipaz2c_fgt2[count.index].private_ip}"
  }
}

