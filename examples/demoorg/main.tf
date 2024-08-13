terraform {
  required_providers {
    sonatypeiq = {
      source = "sonatypeiq"
    }
  }
}

provider "sonatypeiq" {
  url      = "http://localhost:8070"
  username = "admin"
  password = "admin123"
}


data "sonatypeiq_organization" "sandbox" {
  name = "Sandbox Organization"
}

data "sonatypeiq_organization" "root" {
  name = "Root Organization"
}

// resource "sonatypeiq_organization" "sub_org" {
//  name                   = "Sub Organization"
//  parent_organization_id = data.sonatypeiq_organization.root.id
//}

resource "sonatypeiq_organization" "sub_org" {
  name                   = "Sub Organization"
  parent_organization_id = data.sonatypeiq_organization.sandbox.id
}


output "sub_org_id" {
  value = sonatypeiq_organization.sub_org.id
}


