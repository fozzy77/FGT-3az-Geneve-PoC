env_config = {
  dev = {
    vpccidr          = "10.1.0.0/23"
    csvpccidr        = "10.5.0.0/21"
    tgw              = "abcd"
    region           = "eu-west-2"
    az1              = "eu-west-2a"
    az2              = "eu-west-2b"
    az3              = "eu-west-2c"
    size             = "t2.small"
    keyname          = "forti"
    adminsport       = "443"
    bootstrap-fgtvm  = "fgtvm.conf"
    bootstrap-fgtvm2 = "fgtvm2.conf"
    bootstrap-fgtvm3 = "fgtvm3.conf"
    license          = "license.lic"
    license2         = "license2.lic"
    license3         = "license3.lic"
    license_type     = "payg"
    firewall_az2b    = false
    firewall_az2c    = false
  }
  prod = {
    vpccidr          = "10.2.0.0/23"
    csvpccidr        = "10.25.0.0/21"
    tgw              = "efgh"
    region           = "eu-west-2"
    az1              = "eu-west-2a"
    az2              = "eu-west-2b"
    az3              = "eu-west-2c"
    size             = "t2.small"
    keyname          = "forti"
    adminsport       = "443"
    bootstrap-fgtvm  = "fgtvm.conf"
    bootstrap-fgtvm2 = "fgtvm2.conf"
    bootstrap-fgtvm3 = "fgtvm3.conf"
    license          = "license.lic"
    license2         = "license2.lic"
    license3         = "license3.lic"
    license_type     = "payg"
    firewall_az2b    = true
    firewall_az2c    = true
  }
}