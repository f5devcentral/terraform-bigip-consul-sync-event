# Network Infrastructure Automation (NIA)

In this module you will see an example of using [Network Infrastructure Automation (NIA)](https://www.consul.io/docs/nia) to "push" a configuration to the BIG-IP.
We will use the utility `consul-terraform-sync` that will communicate with the Consul service.  When a change is detected it will push a configuration change to the BIG-IP.  

## Running this module
We assume this is brown field deployment, your BIG-IP already has FAST templated installedand now you need to configure the config.hcl file as per your requirement.

copy example config hcl file as shown

```
cp config.hcl.example config.hcl

```
Make sure you have provided the details for bigip address, username, password using terraform.tfvars file or exporting variables values.


In the "example" directory run 
```
consul-terraform-sync -config-file config.hcl 
```
You will see output that indicates that it has updated the BIG-IP configuration.  You can then modify the environment (stop the NGINX Docker container, add additional NGINX nodes) and see that updates will only occur when the environment is modified (vs. every 10 seconds in the previous example).

Example output
```
consul-terraform-sync -config-file config.hcl
{
  "terraform_version": "1.0.11",
  "platform": "darwin_amd64",
  "provider_selections": {},
  "terraform_outdated": false
}
Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Finding f5networks/bigip versions matching "~> 1.11.1"...
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
Created and switched to workspace "AS3"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
{
  "format_version": "0.1",
  "valid": true,
  "error_count": 0,
  "warning_count": 0,
  "diagnostics": []
}

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.AS3.bigip_event_service_discovery.event_pools["nginx"] will be created
  + resource "bigip_event_service_discovery" "event_pools" {
      + id     = (known after apply)
      + taskid = "~Consul_SD~Nginx~nginx_pool"

      + node {
          + id   = "10.0.0.234"
          + ip   = "10.0.0.234"
          + port = 80
        }
      + node {
          + id   = "10.0.0.5"
          + ip   = "10.0.0.5"
          + port = 80
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
module.AS3.bigip_event_service_discovery.event_pools["nginx"]: Creating...
module.AS3.bigip_event_service_discovery.event_pools["nginx"]: Creation complete after 0s [id=~Consul_SD~Nginx~nginx_pool]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

```

## How this works

In the first step you are sending an AS3 declaration that specifies that [Event-Driven Service Discovery](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/discovery.html#event-driven-service-discovery) should be used.

```
...
        "nginx_pool": {
          "class": "Pool",
          "monitors": [
            "http"
          ],
          "members": [
            {
              "servicePort": 80,
              "addressDiscovery": "event"
            }
          ]
        }
...
```
When this is enabled, it creates a new API endpoint on the BIG-IP of `/mgmt/shared/service-discovery/task/~Consul_SD~Nginx~nginx_pool`

In the Terraform code that is used with NIA you will see that this endpoint is used to update the pool members based on the data that is stored in Consul.

```hcl
...
resource "bigip_event_service_discovery" "event_pools" {
  for_each = local.service_ids
  taskid = "~Consul_SD~Nginx~${each.key}_pool"
  dynamic "node" {
    for_each = local.grouped[each.key]
    content {
      id = node.value.node_address
      ip = node.value.node_address
      port = node.value.port
    }
  }
}
...
```
You could also create your own custom event driven endpoints without using AS3 by sending a POST request to `/mgmt/shared/service-discovery/task` with the following payload (assumes pool "test_pool" already exists).  Note that this will wipe out any existing pool members once you send an update.

This could be suitable in an environment where you want NIA to update an existing pool resource.
```
{
    "id": "test_pool",
    "schemaVersion": "1.0.0",
    "provider": "event",
    "resources": [
        {
            "type": "pool",
            "path": "/Common/test_pool",
            "options": {
                "servicePort": 8080
            }
        }
    ],
    "nodePrefix": "/Common/"
}
```
You would then be able to reference this with the taskid of `test_pool`.

To remove event-driven service discovery from `test_pool` you would then issue a `DELETE` to `/mgmt/shared/service-discovery/task/test_pool`.

## More information

This example differs than the one that you will find on the Terraform registry.  Please see the following for another example: https://registry.terraform.io/modules/f5devcentral/app-consul-sync-nia/bigip/latest
