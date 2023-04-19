// Parameters
param privateEndpointName string
param keyVaultId string
param virtualNetworkId string
param subnetId string
param arrayOfNames array
param location string

// Resources
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
  tags: {
    DeplymentModel: 'PaaS'
    Environment: arrayOfNames[1]
    EnvironmentType: substring(arrayOfNames[1], 0, 3)
    Location: location
    Provider: 'Network'
    'Resource Type': 'privateEndpoints'
    Service: arrayOfNames[3]
    ServiceGroup: arrayOfNames[0]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  tags: {}
  properties: {}
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net/${uniqueString(virtualNetworkId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: virtualNetworkId
    }
    registrationEnabled: false
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateEndpointName
        properties: {
          privateDnsZoneId: privateDnsZone.id 
        }
      }
    ]
  }
}

// Outputs
output privateDnsZoneId string = privateDnsZone.id
output privateEndpointId string = privateEndpoint.id
