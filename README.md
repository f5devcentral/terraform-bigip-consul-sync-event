# BIG-IP Application Consul-Terraform-Sync with Service Events Module

This is module which combines multiple resources, it combines the FAST te
mplate deployment and BIG-IP event service discovery of pools together.
Assumption is you have BIG-IP already deployed and now you want to use Consul_terraform_sync for automation. 
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

This is module which combines multiple resources, it combines the FAST template deployment and BIG-IP event service discovery of pools together.

## How to use the module

Assuming you have BIG-IP, Consul Cluster and Consul_terraform_sync running in your infrastructure, create consul.hcl file as shown below

```
driver "terraform" {
  log = true
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
    }
  }
}
#log_level = "trace"
consul {
  address = "Consul_IP:8500"
}

terraform_provider "bigip" {
  address  = "BIGIP_IP:8443"
  username = "admin"
  password = "your_password"
}

task {
  name = "AS3"
  description = "BIG-IP example"
  source = "f5devcentral/consul-sync-event/bigip"
  providers = ["bigip"]
  services = ["nginx"]
  variable_files = ["terraform.tfvars"]
}

```

also create a terraform.tfvars file as shown below

```
address  = "BIGIP_IP"
username = "admin"
password = "your_password"
port = "8443"

```

Here you can see the run output 

```
consul-terraform-sync -config-file config.hcl
{
  "terraform_version": "1.0.11",
  "platform": "darwin_amd64",
  "provider_selections": {},
  "terraform_outdated": false
}
Initializing modules...
Downloading f5devcentral/consul-sync-event/bigip 0.1.0 for AS3...
- AS3 in .terraform/modules/AS3

Initializing the backend...

Successfully configured the backend "consul"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding latest version of hashicorp/archive...
- Finding f5networks/bigip versions matching "~> 1.11.1"...
- Installing hashicorp/archive v2.2.0...
- Installed hashicorp/archive v2.2.0 (signed by HashiCorp)
- Installing f5networks/bigip v1.11.1...
- Installed f5networks/bigip v1.11.1 (signed by a HashiCorp partner, key ID 0F284A6527D73A63)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
Workspace "AS3" already exists
Switched to workspace "AS3".
{
  "format_version": "0.1",
  "valid": true,
  "error_count": 0,
  "warning_count": 0,
  "diagnostics": []
}
module.AS3.bigip_fast_template.consul-webinar: Refreshing state... [id=ConsulWebinar]
module.AS3.bigip_fast_application.nginx-webserver: Refreshing state... [id=Nginx]
module.AS3.bigip_event_service_discovery.event_pools["nginx"]: Refreshing state... [id=~Consul_SD~Nginx~nginx_pool]

Note: Objects have changed outside of Terraform

Terraform detected the following changes made outside of Terraform since the
last "terraform apply":

  # module.AS3.bigip_event_service_discovery.event_pools["nginx"] has been changed
  ~ resource "bigip_event_service_discovery" "event_pools" {
        id     = "~Consul_SD~Nginx~nginx_pool"
        # (1 unchanged attribute hidden)

      + node {
          + id   = "/Consul_SD/10.0.0.214"
          + ip   = "10.0.0.214"
          + port = 80
        }
      + node {
          + id   = "/Consul_SD/10.0.0.251"
          + ip   = "10.0.0.251"
          + port = 80
        }
      - node {
          - id   = "10.0.0.214" -> null
          - ip   = "10.0.0.214" -> null
          - port = 80 -> null
        }
      - node {
          - id   = "10.0.0.251" -> null
          - ip   = "10.0.0.251" -> null
          - port = 80 -> null
        }
    }

Unless you have made equivalent changes to your configuration, or ignored the
relevant attributes using ignore_changes, the following plan may include
actions to undo or respond to these changes.

─────────────────────────────────────────────────────────────────────────────

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.AS3.bigip_event_service_discovery.event_pools["nginx"] will be updated in-place
  ~ resource "bigip_event_service_discovery" "event_pools" {
        id     = "~Consul_SD~Nginx~nginx_pool"
        # (1 unchanged attribute hidden)

      - node {
          - id   = "/Consul_SD/10.0.0.214" -> null
          - ip   = "10.0.0.214" -> null
          - port = 80 -> null
        }
      - node {
          - id   = "/Consul_SD/10.0.0.251" -> null
          - ip   = "10.0.0.251" -> null
          - port = 80 -> null
        }
      + node {
          + id   = "10.0.0.214"
          + ip   = "10.0.0.214"
          + port = 80
        }
      + node {
          + id   = "10.0.0.251"
          + ip   = "10.0.0.251"
          + port = 80
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.
module.AS3.bigip_event_service_discovery.event_pools["nginx"]: Modifying... [id=~Consul_SD~Nginx~nginx_pool]
module.AS3.bigip_event_service_discovery.event_pools["nginx"]: Modifications complete after 0s [id=~Consul_SD~Nginx~nginx_pool]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```
