terraform {
  required_providers {
    sonatypeiq = {
      source = "sonatype-nexus-community/sonatypeiq"
    }
  }
}


provider "sonatypeiq" {
  url      = var.nexusiq_url // can't end with /
  username = var.nexusiq_username
  password = var.nexusiq_password
}
