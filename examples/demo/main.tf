variable "nexusiq_url" {}
variable "nexusiq_username" {}
variable "nexusiq_password" {}


# TO output current user list
locals {
  users_files = {
    for file in fileset("${path.module}/config/users/", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("${path.module}/config/users/${file}"))
  }
  users = flatten([for file in local.users_files : file])
  users_config = {
    for user in local.users :
    user.username => {
      username   = user.username
      password   = user.password
      first_name = lookup(user, "first_name", title(user.username))
      last_name  = lookup(user, "last_name", title(user.username))
      email      = user.email
    }
  }

  orgs_files = {
    for file in fileset("${path.module}/config/organizations/", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("${path.module}/config/organizations/${file}"))
  }
  orgs = flatten([for file in local.orgs_files : file])
  orgs_config = {
    for org in local.orgs :
    org.name => {
      name                     = org.name
      parent_organization_name = lookup(org, "parent", "Root Organization")
    }
  }

  data_org_config = distinct([
    for org in local.orgs :
    lookup(org, "parent", "Root Organization")
  ])

  apps_files = {
    for file in fileset("${path.module}/config/applications/", "*.yaml") :
    trimsuffix(file, ".yaml") => yamldecode(file("${path.module}/config/applications/${file}"))
  }
  apps = flatten([for file in local.apps_files : file])
  apps_config = {
    for app in local.apps :
    app.name => {
      name              = app.name
      organization_name = app.parent
    }
  }

  data_app_config = distinct(
    setsubtract(
      [
        for app in local.apps :
        app.parent
      ],
      local.data_org_config
    )
  )
}


# 
resource "local_file" "generated" {
  content = templatefile("${path.module}/templates/main.tftpl", {
    users_config : local.users_config,
    orgs_config : local.orgs_config,
    data_org_config : local.data_org_config,
    apps_config : local.apps_config,
    data_app_config : local.data_app_config,
  })
  filename             = "./generated.tf"
  directory_permission = "0777"
  file_permission      = "0777"

  lifecycle {
    ignore_changes = [directory_permission, file_permission, filename]
  }
}
