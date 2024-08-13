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


variable "organizations" {
  type        = list(map(any))
  description = "List of organizations"
}


variable "applications" {
  type        = any
  description = "List of applications"
}


variable "users" {
  type = list(object({
    username   = string
    password   = string
    first_name = optional(string)
    last_name  = optional(string)
    email      = string
  }))
  sensitive   = true
  description = "List of users"
}

# TO output current user list
locals {
  users_santinized = {
    username = nonsensitive(var.users.*.username)
  }
}

data "sonatypeiq_organization" "orgs" {
  for_each = toset(concat(var.organizations.*.parent_organization_name))
  name = each.key
}

data "sonatypeiq_organization" "apps" {
  for_each = toset(concat(var.organizations.*.parent_organization_name, var.applications.*.organization_name))
  name = each.key
  depends_on = [ 
    sonatypeiq_organization.organizations
  ]
}




# Create and manage Users for Sonatype IQ Server
resource "sonatypeiq_user" "users" {
  count      = length(var.users)
  username   = var.users[count.index].username
  password   = var.users[count.index].password
  first_name = var.users[count.index].first_name == "" ? var.users[count.index].first_name : title(var.users[count.index].username)
  last_name  = var.users[count.index].last_name == "" ? var.users[count.index].last_name : title(var.users[count.index].username)
  email      = var.users[count.index].email
}



resource "sonatypeiq_organization" "organizations" {
  for_each =  { for obj in var.organizations : obj.name => obj }
  name                   = each.value.name
  parent_organization_id = data.sonatypeiq_organization.orgs[each.value.parent_organization_name].id
}


resource "sonatypeiq_application" "applications" {
  for_each =  { for obj in var.applications : obj.name => obj }
  name            = each.value.name
  public_id       = replace(chomp(each.value.name), " ", "-")
  organization_id = data.sonatypeiq_organization.apps[each.value.organization_name].id
}
