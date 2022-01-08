
A Terraform script to deploy a fleet of FortiGate-VMs on AWS with Gateway Load Balancer intergration.

## Requirements
* [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) >= 1.0.0
* Terraform Provider AWS >= 3.70.0
* Terraform Provider Template >= 2.2.0
* FOS Version >= 7.0.3

## Deployment overview
NOTE This is a work in progress and such you should validate the assumptions below and check this prior to any production deployment

Terraform deploys the following components:
   - 2 AWS VPCs
   - 1 TGW

   - Customer1 VPC with 2 private subnets split two different AZs
           - 1 Route table with private subnet associations, 1 default route with target to TGW Attachment
           - SSM endpoints provisioned in subnet "cs_private_1" az2a ready for an ec2 instance with SSMbootcore IAM policy for PoC traffic flow tests
   
   
   - FGT VPC with 1 public, 1 private, 1 gwlb, and 1 transit gateway subnet in each AZ.  
           - 1 Internet Gateway (VPC Wide)
           - 3 NAT Gateways (1 per AZ, per FGT instance)
           All Per FGT
                - 1 default route with target to NAT (Sec-GWLBe-azxx), and back to the TGW (Sec-NATGW-azxx)
                - 1 Route table with gwlb subnet association and genenve tunnel (Sec-Data-azx), 
                - 1 Route table with transit gateway subnet association (Sec-TGW-az2x)
                - 1 Route table with Public access via the IGW and also a route back via the TGW attachment.
        
        - Up to Three FortiGate-VMs instances with 2 NICs, 1 per AZ : 
           - port1 on public subnet and port2 on private subnet in one AZ
           - port2 will be in its own FG-traffic vdom.
           - An array of geneve interfaces will be created based on port2 during bootstrap and this will be the interface where traffic will be received from the   Gateway Load Balancer from AZs from the TGW.
           - Conditional Logic creation for FGT located in az2b and az2c.
         - Two basic Network Security Group rules: 
            -  one for external, 22 and 443 from anyhwere inbound
            -  one for internal, 10.0.0.0/8 any inbound
         - One Gateway Load Balancer with targets to FortiGates in each AZ.
         - A basic firewall deny statement for http connections, followed by an allow statement policy for https connections as a PoC



## Topology overview (an example of the subnet breakdown)
Customer VPC (10.5.0.0/21)
       private-az1  (10.5.0.0/26)
       private-az2  (10.5.0.64/26)
       private-az3  (10.5.0.128/26)
       endpoint-az1  (10.5.0.192/26)
       endpoint-az2  (10.5.1.0/26)
       endpoint-az3  (10.5.1.64/26)
FortiGate Security VPC (10.1.0.0/23)
       public-az1   (10.1.0.0/28)
       private-az1  (10.1.0.48/28)
       transit-az1  (10.1.0.96/28)
       gwlb-az1     (10.1.0.144/28)
       public-az2   (10.1.0.16/28)
       private-az2  (10.1.0.64/28)
       transit-az2  (10.1.0.112/28)
       gwlb-az2     (10.1.0.160/28)
       public-az3   (10.1.0.32/24)
       private-az3  (10.1.0.80/28)
       transit-az3  (10.1.0.128/24)
       gwlb-az3     (10.1.0.178/28)

Traffic that Initiates connection from the Customer VPC within the csprivatesubnetaz1 or csprivatesubnetaz2, will be
Sent to the TGW, which inturn will forward to AZ localised GWLBe.

Traffic will be recived by the fortinet via a multi-mesh geneve flow (in that any TGW AZ attached zone can connect to any FGT instance)

Output will include the information necessary to log in to the FortiGate-VM instances:
```sh
Outputs: (using the dev workspace)

Changes to Outputs:
  + CSendpoint_subnets     = (known after apply)
  + CSprivate_subnets      = (known after apply)
  + CSvpc                  = (known after apply)
  + FGT1-Password          = (known after apply)
  + FGT1-PublicIP          = (known after apply)
  + FGT2-Password          = "Skipped"
  + FGT2-PublicIP          = "Skipped"
  + FGT3-Password          = "Skipped"
  + FGT3-PublicIP          = "Skipped"
  + FGTgwlbsubnets         = (known after apply)
  + FGTprivate_subnets     = (known after apply)
  + FGTpublic_subnets      = (known after apply)
  + FGTtransit_subnets     = (known after apply)
  + FGTvpc                 = (known after apply)
  + LoadBalancerPrivateIP  = (known after apply)
  + LoadBalancerPrivateIP2 = "Skipped"
  + LoadBalancerPrivateIP3 = "Skipped"
  + Username               = "admin"

