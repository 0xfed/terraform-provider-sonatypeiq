terraform {
  required_providers {
    sonatypeiq = {
      source  = "terraform.local/local/sonatypeiq"
      version = "1.0.0"
    }
  }
}


provider "sonatypeiq" {
  url      = var.nexusiq_url // can't end with /
  username = var.nexusiq_username
  password = var.nexusiq_password
}
