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

  orgs = { for org in data.sonatypeiq_organizations.all.organizations :
    org.name => {
      name = org.name,
      id   = org.id
    }
  }

  apps = { for app in data.sonatypeiq_applications.all.applications :
    app.name => {
      name = app.name,
      id   = app.id
    }
  }

}

data "sonatypeiq_organizations" "all" {
  # should be the one with deepest hierarchy
  depends_on = [sonatypeiq_organization.Dev]
}

data "sonatypeiq_applications" "all" {
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

resource "sonatypeiq_organization" "TestSB" {
  name                   = "Test Sanbox"
  parent_organization_id = data.sonatypeiq_organization.root.id
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





resource "sonatypeiq_application" "Blog" {
  name            = "Blog"
  public_id       = "blog"
  organization_id = sonatypeiq_organization.Dev.id
}

resource "sonatypeiq_application" "Web" {
  name            = "Web"
  public_id       = "web"
  organization_id = sonatypeiq_organization.TestSB.id
}


resource "sonatypeiq_application_role_membership" "all" {
  for_each       = { for obj in local.appsroles : "${obj.app}_${data.sonatypeiq_role.roles[obj.role].id}_${obj.member}" => obj }
  application_id = local.apps[each.value.app].id
  role_id        = data.sonatypeiq_role.roles[each.value.role].id
  user_name      = each.value.member
}


resource "sonatypeiq_organization_role_membership" "all" {
  for_each        = { for obj in local.orgsroles : "${obj.org}_${data.sonatypeiq_role.roles[obj.role].id}_${obj.member}" => obj }
  organization_id = local.orgs[each.value.org].id
  role_id         = data.sonatypeiq_role.roles[each.value.role].id
  user_name       = each.value.member
}


resource "sonatypeiq_source_control" "app_web" {
  owner_type                        = "application"
  owner_id                          = sonatypeiq_application.Web.id
  base_branch                       = "main"
  remediation_pull_requests_enabled = true
  pull_request_commenting_enabled   = true
  source_control_evaluation_enabled = false
  scm_provider                      = "github"
  repository_url                    = "https://github.com/0xfed/terraform-provider-sonatypeiq.git"
}

resource "sonatypeiq_source_control" "org_Dev" {
  # uncomment or complemet
  owner_type                        = "organization"
  owner_id                          = sonatypeiq_organization.TestSB.id
  remediation_pull_requests_enabled = true
  pull_request_commenting_enabled   = true
  source_control_evaluation_enabled = true
  scm_provider                      = "github"
  base_branch                       = "my-cool-branch"
}


resource "sonatypeiq_system_config" "iq_server" {
  base_url       = "http://localhost:8070/"
  force_base_url = false
  
}

output "local_org" {
  value = local.orgs
}
output "local_app" {
  value = local.apps
}