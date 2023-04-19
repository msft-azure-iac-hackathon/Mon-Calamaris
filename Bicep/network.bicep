@description('Location for all Resources.') 
param location string = resourceGroup().location

@description('Name prefix to generate names of resources.')
param namePrefix string

@description('A list of address blocks reserved for this virtual network in CIDR notation.')
param vnetAddressPrefixes array

@description('Indicates if DDoS protection is enabled for all the protected resources in the virtual network. It requires a DDoS protection plan associated with the resource.')
param vnetEnableDdosProtection bool = false

@description('The list of DNS servers IP addresses.')
param vnetDnsServers array = []

@description('A list of subnets in a Virtual Network, including Application/Network Security Groups configuration and Route Tables.')
param vnetSubnets array

@description('A list of Private DNS Zones with corresponding A records and Virtual Network Links')
param vnetPrivateDnsZones array

module virtualNetwok 'Components/virtualNetwork.bicep' = {
  name: '${namePrefix}-vnt'
  dependsOn: [
    networkSecurityGroups
    routeTables
  ]
  params: {
    location: location
    namePrefix: namePrefix
    vnetEnableDdosProtection: vnetEnableDdosProtection
    vnetDnsServers: vnetDnsServers
    vnetAddressPrefixes: vnetAddressPrefixes
    vnetSubnets: vnetSubnets
  }
}

module networkSecurityGroups 'Components/networkSecurityGroup.bicep' = [for vnetSubnet in vnetSubnets: if (!empty(vnetSubnet.networkSecurityGroup)) {
  name: '${namePrefix}-nsg-${vnetSubnet.name}'
  dependsOn: applicationSecurityGroups
  params: {
   location: location
   nsgName: '${namePrefix}-nsg-${vnetSubnet.name}'
   nsgRules: vnetSubnet.networkSecurityGroup.rules
  }
 }]

module applicationSecurityGroups 'Components/applicationSecurityGroup.bicep' = [for vnetSubnet in vnetSubnets: {
  name: '${namePrefix}-asg-${vnetSubnet.name}'
  params: {
    location: location
    asgName: vnetSubnet.name
  }
}]

module routeTables 'Components/routeTable.bicep' = [for vnetSubnet in vnetSubnets: if (!empty(vnetSubnet.routeTable)){
 name: '${namePrefix}-udr-${vnetSubnet.name}'
 params: {
  location: location
  udrName: '${namePrefix}-udr-${vnetSubnet.name}'
  udrRoutes: vnetSubnet.routeTable.routes
 }
}]

module privateDnsZones 'Components/privateDnsZone.bicep' = [ for privateDnsZone in vnetPrivateDnsZones: {
  name: privateDnsZone.name
  dependsOn: [
    virtualNetwok
  ]
  params: {
    location: 'global'
    pdnszName: privateDnsZone.name
    pdnszVirtualNetworkLinks: privateDnsZone.pdnszVirtualNetworkLinks
    pdnszARecords: privateDnsZone.pdnszARecords
  }
}]
