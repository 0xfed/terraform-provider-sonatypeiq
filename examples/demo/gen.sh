#!/bin/bash
rm generated.tf
terraform apply -target local_file.generated -auto-approve
terraform validate
terraform fmt