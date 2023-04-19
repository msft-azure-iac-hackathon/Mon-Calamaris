param namePrefix string
param vnetAddressPrefixes array
param vnetEnableDdosProtection bool
param vnetDnsServers array = []
param vnetSubnets array
param location string = resourceGroup().location

var vnetName = '${namePrefix}-vnt'
var resourcegroupID = resourceGroup().id

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' =  {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    dhcpOptions: {
      dnsServers: vnetDnsServers
    }
    enableDdosProtection: vnetEnableDdosProtection
  }
  
  resource subnet 'subnets@2022-07-01' = [ for vnetSubnet in vnetSubnets : {
    name: vnetSubnet.name
    properties: {
      addressPrefix: vnetSubnet.addressPrefix
      networkSecurityGroup: (empty(vnetSubnet.networkSecurityGroup) ? json('null') : json(concat('{"id": "',resourcegroupID, '/providers/Microsoft.Network/networkSecurityGroups/', namePrefix, '-nsg-', vnetSubnet.name, '"}')))
      routeTable: (empty(vnetSubnet.routeTable) ? json('null') : json(concat('{"id": "',resourcegroupID, '/providers/Microsoft.Network/routeTables/', namePrefix, '-udr-', vnetSubnet.name, '"}')))
      serviceEndpoints: vnetSubnet.serviceEndpoints
      delegations: vnetSubnet.delegations
      privateEndpointNetworkPolicies: vnetSubnet.privateEndpointNetworkPolicies
      privateLinkServiceNetworkPolicies: vnetSubnet.privateLinkServiceNetworkPolicies
    }

  }]
}
