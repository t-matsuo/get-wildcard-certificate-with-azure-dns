# get-wildcard-certificate-with-azure-dns

This script gets a wildcard certificate using azure dns.
You don't need open any tcp port.

## Requirement

* install az-cli(>2.5.1) and login
   * az-cli <= 2.5.1 has a bug : https://github.com/Azure/azure-cli/issues/12804 
* install cerbot
* create a zone on azure dns manually

## Usage

    ./get-certificate.sh DomainName MailAddress AzureResourceGroup
    ex ./get-certificate.sh test.example.com test@test.example.com my-resource-group


