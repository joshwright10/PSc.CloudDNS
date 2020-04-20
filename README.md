[![Build Status](https://dev.azure.com/joshwright10/PSc.CloudDNS/_apis/build/status/joshwright10.PSc.CloudDNS?branchName=master)](https://dev.azure.com/joshwright10/PSc.CloudDNS/_build/latest?definitionId=1&branchName=master)
[![Documentation Status](https://readthedocs.org/projects/pscclouddns/badge/?version=latest)](https://pscclouddns.readthedocs.io/en/latest/?badge=latest)


# PSc.CloudDNS

PSc.CloudDNS is a module to help assist with the migration of DNS records from one cloud platform to another.

## Documentation

Documentation Site: [readthedocs.io](https://pscclouddns.readthedocs.io/en/latest)


## Release Notes

[Release Notes](https://github.com/joshwright10/PSc.CloudDNS/blob/master/docs/RELEASE.md)

## Supported Providers
* CSC / Netnames
* Azure DNS

## CSC / Netnames
At the time of development (2019), CSC did not have an API for the purpose of migrating records to another provider. The only way we could acheive a migration from CSC, is by exporting their zone files for each DNS zone and then processing the files using `ConvertFrom-PScCSCZoneFile` in order to work with them in PowerShell.

Once the DNS records have been recreated in the target platform, the root NS records need to be manually changed to point to the new NS servers. This change of NS records may to incure a cost (around $15 per domain in 2019).

## Azure DNS
Azure DNS (in 2019) was not a DNS registar and so, it was only possible to migrate the management of DNS records to Azure DNS, not the registration and management. This module can help with migration of DNS record management.

### Requirements for Azure
* Az PowerShell Module
* At least "DNS Zone Contributor" permissions

# Installing PSc.CloudDNS

PSc.CloudDNS requires a Windows OS running PowerShell 5.0.

## Install from the Powershell Gallery
    Find-Module -Name "PSc.CloudDNS" | Install-Module -Scope CurrentUser

## Import Module
    Import-Module -Name "PSc.CloudDNS"

# Using PSc.CloudDNS

## Existing Use Cases

* [Migrate from CSC to Azure DNS](https://pscclouddns.readthedocs.io/en/latest/migratefromCSCtoAzure/)