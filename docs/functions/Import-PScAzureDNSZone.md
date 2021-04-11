---
external help file: PSc.CloudDNS-help.xml
Module Name: PSc.CloudDNS
online version: http://pscclouddns.readthedocs.io/en/latest/functions/Import-PScAzureDNSZone.md
schema: 2.0.0
---

# Import-PScAzureDNSZone

## SYNOPSIS
Creates Azure DNS Zone and Records based PScDNSRecordSet objects.

## SYNTAX

```
Import-PScAzureDNSZone [-Records] <Object> [-TenantId] <String> [-SubscriptionId] <String>
 [-ResourceGroupName] <String> [[-TTL] <Int32>] [[-Tag] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
Creates Azure DNS Zone and Records based PScDNSRecordSet objects.

## EXAMPLES

### EXAMPLE 1
```
$Records = ConvertFrom-CSCZoneFile -ZoneFile "C:\Temp\example.com.txt"
Import-PScAzureDNSZone -Records $Records -TenantId "xxxx-xxxx-xxxx-xxxx" -SubscriptionId "aaaa-aaaa-aaaa-aaaa" -ResourceGroupName "rg-dns" -TTL 3600
```

Creates the DNS Zone and DNS records that are passed in via the Records parameter.
The DNS Zone and records are created in the Subscription and Resource Group specified.
These must exist in advance.

### EXAMPLE 2
```
$Records = ConvertFrom-CSCZoneFile -ZoneFile "C:\Temp\example.com.txt"
Import-PScAzureDNSZone -Records $Records -TenantId "xxxx-xxxx-xxxx-xxxx" -SubscriptionId "aaaa-aaaa-aaaa-aaaa" -ResourceGroupName "rg-dns" -TTL 3600 -Tag @{CostCentre="VALUE"}
```

Creates the DNS Zone and DNS records that are passed in via the Records parameter.
The DNS Zone and records are created in the Subscription and Resource Group specified.
These must exist in advance.
The Tag of CostCentre with a value of EXAMPLE is applied.

## PARAMETERS

### -Records
Specifies the records that are to be created.
These must be PScDNSRecordSet objects.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
Specifies the ID of the tenant in which the records are to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SubscriptionId
Specifies the ID of the Subscription in which the records are to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourceGroupName
Specifies the resource group in which the records are to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TTL
Specifies the TTL to be used for all records.
Default value is 3600

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Key-value pairs in the form of a hash table.
For example: @{key0="value0";key1=$null;key2="value2"}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[http://pscclouddns.readthedocs.io/en/latest/functions/Import-PScAzureDNSZone.md](http://pscclouddns.readthedocs.io/en/latest/functions/Import-PScAzureDNSZone.md)

