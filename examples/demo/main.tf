variable "nexusiq_url" {}
variable "nexusiq_username" {}
variable "nexusiq_password" {}

variable "organizations" {
  type        = any
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

  appsroles = distinct(flatten([
    for app in var.applications : [
      for rbac in app.rbac : [
        for member in rbac.members : {
          app    = app.name
          role   = rbac.role
          member = member
        }
      ]
    ]
  ]))

  orgsroles = distinct(flatten([
    for org in var.organizations : [
      for rbac in org.rbac : [
        for member in rbac.members : {
          org    = org.name
          role   = rbac.role
          member = member
        }
      ]
    ]
  ]))

  orgs = { for org in data.sonatypeiq_organizations.all.organizations:
    org.name => {
      name = org.name,
      id = org.id
    }
  }
}

data "sonatypeiq_organizations" "all" {
  # should be the one with deepest hierarchy
  depends_on = [sonatypeiq_organization.Dev]
}

# To create lookupable roles
data "sonatypeiq_role" "roles" {
  for_each   = { for obj in toset(flatten(var.applications.*.rbac)) : obj.role => obj... }
  name       = each.key
  depends_on = [data.sonatypeiq_organizations.all]
}

data "sonatypeiq_organization" "root" {
  id = "ROOT_ORGANIZATION_ID"
}

resource "sonatypeiq_organization" "Test" {
  name                   = "Test Zone"
  parent_organization_id = data.sonatypeiq_organization.root.id
}

resource "sonatypeiq_organization" "Dev" {
  name                   = "Dev"
  parent_organization_id = sonatypeiq_organization.ASandbox.id
}


resource "sonatypeiq_organization" "ASandbox" {
  name                   = "Another Sanbox"
  parent_organization_id = sonatypeiq_organization.Test.id
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





resource "sonatypeiq_application" "all" {
  for_each        = { for obj in var.applications : obj.name => obj } // 
  name            = each.value.name
  public_id       = replace(chomp(each.value.name), " ", "-")
  organization_id = local.orgs[each.value.organization_name].id
}


resource "sonatypeiq_application_role_membership" "all" {
  for_each       = { for obj in local.appsroles : "${obj.app}_${obj.role}_${obj.member}" => obj }
  application_id = sonatypeiq_application.all[each.value.app].id
  role_id        = data.sonatypeiq_role.roles[each.value.role].id
  user_name      = each.value.member
}


resource "sonatypeiq_organization_role_membership" "all" {
  for_each        = { for obj in local.orgsroles : "${obj.org}_${obj.role}_${obj.member}" => obj }
  organization_id = local.orgs[each.value.org].id
  role_id         = data.sonatypeiq_role.roles[each.value.role].id
  user_name       = each.value.member
}


output "local_org" {
  value = local.orgs
}