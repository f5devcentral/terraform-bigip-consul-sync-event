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
  address = "34.201.117.163:8500"
}

terraform_provider "bigip" {
  address  = "34.198.3.242:8443"
  username = "admin"
  password = "D2QlstYySK"
}

task {
  name = "AS3"
  description = "BIG-IP example"
  source = "../"
  providers = ["bigip"]
  services = ["nginx"]
  variable_files = ["terraform.tfvars"]
}

