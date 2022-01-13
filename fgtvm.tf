// FGTVM instance

resource "aws_network_interface" "eth0" {
  description = "fgtvm-port1"
  subnet_id   = aws_subnet.publicsubnet["public_az2a"].id
}

resource "aws_network_interface" "eth1" {
  description       = "fgtvm-port2"
  subnet_id         = aws_subnet.privatesubnet["private_az2a"].id
  source_dest_check = false
}

data "aws_network_interface" "eth1" {
  id = aws_network_interface.eth1.id
}

//
data "aws_network_interface" "vpcendpointipaz2a_fgt1" {
  depends_on = [aws_vpc_endpoint.gwlbendpoints["az2a"]]
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

data "aws_network_interface" "vpcendpointipaz2b_fgt1" {
  depends_on = [aws_vpc_endpoint.gwlbendpoints["az2a"]]
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

data "aws_network_interface" "vpcendpointipaz2c_fgt1" {
  depends_on = [aws_vpc_endpoint.gwlbendpoints["az2a"]]
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

resource "aws_network_interface_sg_attachment" "publicattachment" {
  depends_on           = [aws_network_interface.eth0]
  security_group_id    = aws_security_group.public_allow.id
  network_interface_id = aws_network_interface.eth0.id
}

resource "aws_network_interface_sg_attachment" "internalattachment" {
  depends_on           = [aws_network_interface.eth1]
  security_group_id    = aws_security_group.allow_all.id
  network_interface_id = aws_network_interface.eth1.id
}


resource "aws_instance" "fgtvm" {
  ami               = local.config.license_type == "byol" ? var.fgtvmbyolami[local.config.region] : var.fgtvmami[local.config.region]
  instance_type     = local.config.size
  availability_zone = local.config.az1
  key_name          = local.config.keyname
  user_data         = data.template_file.FortiGate.rendered

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
    network_interface_id = aws_network_interface.eth0.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 1
  }

  tags = {
    Name = "FortiGateVM"
  }
}


data "template_file" "FortiGate" {
  template = file("${local.config.bootstrap-fgtvm}")
  vars = {
    type         = "${local.config.license_type}"
    license_file = "${local.config.license}"
    adminsport   = "${local.config.adminsport}"
    cidr         = "${local.config.vpccidr}"
    gateway      = cidrhost(local.settings_pvt.private_az2a.subnet, 1)
    endpointip   = "${data.aws_network_interface.vpcendpointipaz2a_fgt1.private_ip}"
    endpointip2b = "${data.aws_network_interface.vpcendpointipaz2b_fgt1.private_ip}"
    endpointip2c = "${data.aws_network_interface.vpcendpointipaz2c_fgt1.private_ip}"
  }
}

