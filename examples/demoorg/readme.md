## Run
### Install Terraform
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Run Nexus IQ
```bash
docker run -p 8070:8070 -d nexusiq
```

### The bug:
Inside `demoorg`:
 
First, run this config
```
resource "sonatypeiq_organization" "sub_org" {
 name                   = "Sub Organization"
# parent_organization_id = data.sonatypeiq_organization.root.id
  parent_organization_id = data.sonatypeiq_organization.sandbox.id
}
```

Next, run this

```
resource "sonatypeiq_organization" "sub_org" {
 name                   = "Sub Organization"
 parent_organization_id = data.sonatypeiq_organization.root.id
#  parent_organization_id = data.sonatypeiq_organization.sandbox.id
}
```