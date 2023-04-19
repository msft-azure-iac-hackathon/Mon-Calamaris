param location string = resourceGroup().location
param udrDisableBgpRoutes bool = false
param udrName string
param udrRoutes array

resource routeTable 'Microsoft.Network/routeTables@2022-07-01' = {
  name: udrName
  location: location
  properties: {
    disableBgpRoutePropagation: udrDisableBgpRoutes
    routes: udrRoutes
  }
}
