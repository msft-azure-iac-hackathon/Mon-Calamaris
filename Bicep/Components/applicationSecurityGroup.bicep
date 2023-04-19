param location string = resourceGroup().location
param asgName string

resource applicationSecurityGroup 'Microsoft.Network/applicationSecurityGroups@2022-07-01' = {
  name: asgName
  location: location
  properties:{
  }
}
