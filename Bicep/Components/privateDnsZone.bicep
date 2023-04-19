@description('Resouce Location.')
param location string = 'global'

@description('The name of the Private DNS zone.')
param pdnszName string

@description('List of VirtualNetworks to be linked with the Private DNS Zone.')
param pdnszVirtualNetworkLinks array

@description('List of A-records to be created in the Private DNS Zone.')
param pdnszARecords array

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: pdnszName
  location: location
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for virtualNetworkLink in pdnszVirtualNetworkLinks: {
  name: '${privateDnsZone.name}/${virtualNetworkLink.name}-link'
  location: location
  properties: {
    virtualNetwork: {
      id: virtualNetworkLink.id
    }
    registrationEnabled: virtualNetworkLink.autoRegistration
  }
}]

resource privateARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [for aRecord in pdnszARecords: {
  name: '${privateDnsZone.name}/${aRecord.name}'
  properties: {
    ttl: aRecord.ttl
    aRecords: [
      {
        ipv4Address: aRecord.ipv4
      }
    ]

  }
}]
