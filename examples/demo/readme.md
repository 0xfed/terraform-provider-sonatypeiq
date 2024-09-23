### Setup

```bash
python3 merge-spec.py && docker run --rm -v "${PWD}:/local" openapitools/openapi-generator-cli batch --clean /local/go.yaml
go mod edit -replace github.com/0xfed/nexus-iq-api-client-go=/workspaces/nexus-iq-api-client/out/go/
make build
#mkdir -p ~/.terraform.d/plugins/terraform.local/local/sonatypeiq/1.0.0/linux_amd64/
#ln -s `pwd`/terraform-provider-sonatypeiq ~/.terraform.d/plugins/terraform.local/local/sonatypeiq/1.0.0/linux_amd64/terraform-provider-sonatypeiq_v1.0.0
cp .terraformrc ~/
terraform init
bash gen.sh
```