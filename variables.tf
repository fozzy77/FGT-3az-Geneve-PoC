#### AMIs are for FGTVM-AWS(PAYG) - 7.0.3
variable "fgtvmami" {
  type = map(any)
  default = {
    eu-west-2 = "ami-029ffbc3b4ee2ea69"
  }
}

#### AMIs are for FGTVM AWS(BYOL) - 7.0.3
variable "fgtvmbyolami" {
  type = map(any)
  default = {
    eu-west-2 = "ami-029ffbc3b4ee2ea69"
  }
}

variable "env_config" {
  type = map(object({
    vpccidr          = string
    csvpccidr        = string
    tgw              = string
    region           = string
    az1              = string
    az2              = string
    az3              = string
    size             = string
    keyname          = string
    adminsport       = string
    bootstrap-fgtvm  = string
    bootstrap-fgtvm2 = string
    bootstrap-fgtvm3 = string
    license          = string
    license2         = string
    license3         = string
    license_type     = string
    firewall_az2b    = bool
    firewall_az2c    = bool
  }))
}