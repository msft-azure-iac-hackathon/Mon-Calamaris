param namePrefix string = 'mc-frontend'
param location string = resourceGroup().location
param appServicePlanSkuTier string = 'basic'
param appServicePlanSkuName string = 'B1'
param publicNetworkAccessEnabled bool = false
param vnetSubnetId string

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: '${namePrefix}-functionApp'
  location: location
  kind: 'function, linux'
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION',
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME',
          value: 'powershell'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${listKeys(storageAccount.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
        }
      ]
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
      }
      use32BitWorkerProcess: false
      ftpsState:'FtpsOnly'
      linuxFxVersion: 'PowerShell|7.2'
      alwaysOn: true
      vnetRouteAllEnabled: true
    }
    serverFarmId: appSerivcePlan.id
    clientAffinityEnabled: false
    httpsOnly: true
    publicNetworkAccess: publicNetworkAccessEnabled
    virtualNetworkSubnetId: vnetSubnetId
  }

}

resource appSerivcePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${namePrefix}-appSerivcePlan'
  location: location
  kind: 'linux'
  properties: {
      targetWorkerCount: 1
  }
  sku: {
    tier: appServicePlanSkuTier
    name: appServicePlanSkuName
  }

}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${namePrefix}-storageAccount'
  location: location
}
