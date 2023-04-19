param location string = resourceGroup().location
param nsgName string
param nsgRules array

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: nsgRules
  }
}
