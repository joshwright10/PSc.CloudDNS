---
external help file: PSc.CloudDNS-help.xml
Module Name: PSc.CloudDNS
online version: http://pscclouddns.readthedocs.io/en/latest/functions/ConvertFrom-PScCSCZoneFile.md
schema: 2.0.0
---

# ConvertFrom-PScCSCZoneFile

## SYNOPSIS
Converts each entry in a DNS Zone File downloaded from the CSC domain Management portal into an individual object.

## SYNTAX

```
ConvertFrom-PScCSCZoneFile [-ZoneFile] <FileInfo[]> [<CommonParameters>]
```

## DESCRIPTION
Converts each entry in a DNS Zone File downloaded from the CSC domain Management portal into an individual object.

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-PScCSCZoneFile -ZoneFile "C:\Temp\example.com.txt"
```

Reads the Zone File and converts each entry into a PScDNSRecordSet object.

### EXAMPLE 2
```
ConvertFrom-PScCSCZoneFile -ZoneFile "C:\Temp\example.com.txt","C:\Temp\example2.com.txt"
```

Reads the Zone Files and converts each entry into a PScDNSRecordSet object.

## PARAMETERS

### -ZoneFile
Specifies the CSC Zone file to be converted.
One or more zone files can be passed at the same time.

```yaml
Type: FileInfo[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### TXT zone file export from the CSC Domain Management Portal.
## OUTPUTS

### PScDNSRecordSet
## NOTES
The CSC Zone file does not contain URL Forwarding Records, so these will need to be handled separately.
Any Root NS records will be ignored.
Any NS record that refers to netnames.net will be ignored.

## RELATED LINKS

[http://pscclouddns.readthedocs.io/en/latest/functions/ConvertFrom-PScCSCZoneFile.md](http://pscclouddns.readthedocs.io/en/latest/functions/ConvertFrom-PScCSCZoneFile.md)

