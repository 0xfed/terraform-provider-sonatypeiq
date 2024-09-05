#!/bin/bash
set -xe
terraform validate || rm generated.tf
terraform apply -target local_file.generated -auto-approve
terraform validate
terraform fmt