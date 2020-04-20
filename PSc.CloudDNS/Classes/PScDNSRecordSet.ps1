enum PScDNSRecordType {
    A;
    AAAA;
    CNAME;
    MX;
    TXT;
    NS;
    PTR;
    SRV;
}

Class PScDNSRecordSet {

    # Properties
    [string]$ZoneName
    [string]$Name
    [int]$TTL
    [PScDNSRecordType]$RecordType
    [string]$Value
    [int]$Priority
    [int]$Weight
    [int]$Port

    # Constructor
    PScDNSRecordSet([string]$ZoneName, [string]$Name, [int]$TTL, [PScDNSRecordType]$RecordType, [string]$Value, [int]$Priority, [int]$Weight, [int]$Port) {
        $this.ZoneName = $ZoneName
        $this.Name = $Name
        $this.TTL = $TTL
        $this.RecordType = $RecordType
        $this.Value = $Value
        $this.Priority = $Priority
        $this.Weight = $Weight
        $this.Port = $Port
    }

    [void]SetTTL([int]$TTL) {
        if ($TTL -eq 0) {
            $this.TTL = 3600
        }
        else {
            $this.TTL = $TTL
        }
    }
}