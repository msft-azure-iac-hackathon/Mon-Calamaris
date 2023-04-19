@description('location of resource group.')
param location string = resourceGroup().location

@description('Define a resource ID that needs to have a private endpoint.')
param resourceIdentifier string

@description('Define a private endpoint type (blob, file, vault, etc.)')
param privateEndpointType string

@description('Id of the vnet where it needs to be deployed.')
param virtualNetworkId string

@description('ID of the subnet where the private endpoint will be placed.')
param subnetName string

@description('ID of private DNS zone.')
param privateDnsZoneId string

@description('Optional. Application security groups in which the private endpoint IP configuration is included.')
param applicationSecurityGroups array = []

var privateEndpointName = '${resourceName}-pe'
var resourceName = last(split(resourceIdentifier, '/'))
var subnetId = '${virtualNetworkId}/subnets/${subnetName}'
var networkInteraceName = '${privateEndpointName}-nic0'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  location: location
  name: privateEndpointName
  properties: {
    applicationSecurityGroups: applicationSecurityGroups
    customNetworkInterfaceName: networkInteraceName
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceIdentifier
          groupIds: [
            privateEndpointType
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: subnetId
    }
  }
  tags: {}
}



resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateEndpointName
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

output networkInterfaceName string = networkInteraceName
