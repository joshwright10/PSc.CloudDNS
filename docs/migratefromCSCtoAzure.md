# Migrate from CSC to Azure DNS

If the DNS Zone does not exist in Azure DNS, it will be automatically created.
However, the zone must not contain any of the same records that are due to be imported. This will cause `Import-PScAzureDNSZone` to fail and you will need to clear the records and start again.

> **It is recommended to start with no DNS Zone in Azure or an empty one.**

    # Prepare variables
    $tennantId = "e83db882-4a71-4e5e-8288-999d79fad4b7"
    $subscriptionId = "ae7b9e6a-3459-452e-9dfc-43accf330730"
    $ResourceGroupName = "rg-dns"

Connect to Azure using an account with the required permissions.

    # Connect to Azure
    Connect-AzAccount -Tenant $tennantId -Subscription $subscriptionId

Run `ConvertFrom-PScCSCZoneFile` against the Zone File from CSC in order to convert it into a usable object.

    # Import Module
    Import-Module -Name "PSc.CloudDNS"

    # Convert CSC Zone File
    $Records = ConvertFrom-PScCSCZoneFile -ZoneFile "C:\Temp\consoto.com.txt"

Start the import to create the records in Azure. This could take serval minutes depending on the number of records and connection speed. The TTL value is used to set all records to the same value, as many CSC records do not have TTL values.

    Import-PScAzureDNSZone -Records $Records -TenantId $tennantId -SubscriptionId $subscriptionId -ResourceGroupName $ResourceGroupName -TTL 3600 -Verbose
