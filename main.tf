terraform {
  required_providers {
    bigip = {
      source  = "f5networks/bigip"
      version = "~> 1.11.1"
    }
  }
}
# generate zip file

data "archive_file" "template_zip" {
  type        = "zip"
  source_file = "${path.module}/template/ConsulWebinar.yaml"
  output_path = "${path.module}/template/ConsulWebinar.zip"
}

# deploy fast template

resource "bigip_fast_template" "consul-webinar" {
  name = "ConsulWebinar"
  source = "${path.module}/template/ConsulWebinar.zip"
  md5_hash = filemd5("${path.module}/template/ConsulWebinar.zip")
  depends_on = [data.archive_file.template_zip]
}

resource "bigip_fast_application" "nginx-webserver" {
  template        = "ConsulWebinar/ConsulWebinar"
  fast_json   = <<EOF
{
      "tenant": "Consul_SD",
      "app": "Nginx",
      "virtualAddress": "10.0.0.200",
      "virtualPort": 8080,
       "defpool": "nginx_pool"
}
EOF
  depends_on = [bigip_fast_template.consul-webinar]
}


locals {

  # Create a map of service names to instance IDs
  service_ids = transpose({
    for id, s in var.services : id => [s.name]
  })

  # Group service instances by name
  grouped = { for name, ids in local.service_ids :
    name => [
      for id in ids : var.services[id]
    ]
  }

}
resource "bigip_event_service_discovery" "event_pools" {
  for_each = local.service_ids
  taskid   = "~${var.tenant}~${var.app}~${each.key}_pool"
  dynamic "node" {
    for_each = local.grouped[each.key]
    content {
      id   = node.value.node_address
      ip   = node.value.node_address
      port = node.value.port
    }
  }
depends_on = [bigip_fast_application.nginx-webserver]
}
