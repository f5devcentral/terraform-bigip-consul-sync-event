# BIG-IP Application Consul-Terraform-Sync with Service Events Module

This terraform module leverages consul-terraform-sync to create and update application services on BIG-IP based on registered services within Consul. Please open github issues with feature requests or bugs for further advancement.

Please find more information about setting up your environment with **Consul Network Infrastructure Automation (NIA)** within its [Documentation Page](https://www.consul.io/docs/nia/tasks).

terraform-bigip-app-consul-sync-nia

<p align="left">
<img width="100%"   src="https://raw.githubusercontent.com/f5devcentral/terraform-bigip-app-consul-sync-nia/master/images/cts.drawio.png"> </a>
</p>
                                                                                                                                     
                                                                                                                                     
## Requirements

* BIG-IP AS3 >= 3.20

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| consul-terraform-sync | >= 0.1.0 |
| consul | >= 1.7 |


## Providers

| Name | Version |
|------|---------|
| bigip | ~> 1.3.2 |

## Setup / Notes
