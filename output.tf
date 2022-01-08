
output "FGT1-PublicIP" {
  value = aws_eip.FGTPublicIP.public_ip
}
output "FGT2-PublicIP" {
  value = local.config.firewall_az2b == false ? "Skipped" : aws_eip.FGT2PublicIP[0].public_ip
}
output "FGT3-PublicIP" {
  value = local.config.firewall_az2b == false ? "Skipped" : aws_eip.FGT3PublicIP[0].public_ip
}
output "Username" {
  value = "admin"
}

output "FGT1-Password" {
  value = aws_instance.fgtvm.id
}
output "FGT2-Password" {
  value = local.config.firewall_az2b == false ? "Skipped" : aws_instance.fgtvm2[0].id
}
output "FGT3-Password" {
  value = local.config.firewall_az2c == false ? "Skipped" : aws_instance.fgtvm3[0].id
}
output "LoadBalancerPrivateIP" {
  value = data.aws_network_interface.vpcendpointipaz2a_fgt1.private_ip
}
output "LoadBalancerPrivateIP2" {
  value = local.config.firewall_az2b == false ? "Skipped" : data.aws_network_interface.vpcendpointipaz2b_fgt2[0].private_ip
}
output "LoadBalancerPrivateIP3" {
  value = local.config.firewall_az2c == false ? "Skipped" : data.aws_network_interface.vpcendpointipaz2c_fgt3[0].private_ip
}
output "FGTvpc" {
  value = aws_vpc.fgtvm-vpc.id
}
output "CSvpc" {
  value = aws_vpc.customer-vpc.id
}

output "CSprivate_subnets" {
  value = [for instance in aws_subnet.csprivatesubnet : instance.cidr_block]
}
output "CSendpoint_subnets" {
  value = [for instance in aws_subnet.csendpointsubnet : instance.cidr_block] 
}
output "FGTpublic_subnets" {
  value = [for instance in aws_subnet.publicsubnet : instance.cidr_block]
}
output "FGTprivate_subnets" {
  value = [for instance in aws_subnet.privatesubnet : instance.cidr_block]
}
output "FGTtransit_subnets" {
  value = [for instance in aws_subnet.transitsubnet : instance.cidr_block]
}
output "FGTgwlbsubnets" {
  value = [for instance in aws_subnet.gwlbsubnet : instance.cidr_block]
}

output "pvt_subnet_gw_az2a" {
  value = cidrhost(local.settings_pvt.private_az2a.subnet, 1)
}
output "pvt_subnet_gw_az2b" {
  value = cidrhost(local.settings_pvt.private_az2b.subnet, 1)
}
output "pvt_subnet_gw_az2c" {
  value = cidrhost(local.settings_pvt.private_az2c.subnet, 1)
}
