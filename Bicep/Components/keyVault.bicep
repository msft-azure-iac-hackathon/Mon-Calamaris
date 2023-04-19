// Parameters
param keyVaultId string = ''
param namePrefix string

var keyVaultName = '${namePrefix}-kvt'

@description('SKU for the vault')
@allowed([
  'standard'
  'premium'
])
param keyVaultSku string = 'standard'

@description('Access Policies defining the scope and level of access for different principals')
param keyVaultAccessPolicies array = []

@description('Network Access Control rules for the Key Vault')
param keyVaultNetworkAcls object= {}

@description('Enable the soft delete for the Key Vault')
param keyVaultPurgeSoftDelete bool = true

@description('Enable the purge protection for the Key Vault')
param isPurgeProtectionEnabled bool = true

@description('The resource ID of the Event Hub Namespace used for diagnostic log integration.')
param diagnosticEventHubNamespaceId string = ''

@description('Name of the Event Hub Namespace Authorisation Rule used for diagnostic log integration.')
param diagnosticEventHubAuthorisationRule string = 'RootManageSharedAccessKey'
param deployPrivateEndpoints bool = true

@description('The virtual network resource group where the PEP will be placed.')
param virtualNetworkResourceGroup string = ''
param virtualNetworkId string = ''

@description('The subnet name of the private endpoint.')
param subnetName string = ''

param location string = resourceGroup().location

// Variables
var arrayOfNames = split(keyVaultName, '-')
var kvName = toLower(replace(keyVaultName, '-', ''))
var eventHubAuthorizationRuleId = '${diagnosticEventHubNamespaceId}/authorizationRules/${diagnosticEventHubAuthorisationRule}'
var privateEndpointName = toLower('${keyVaultName}-vault')
var subnetId = '${virtualNetworkId}/subnets/${subnetName}'

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  tags: {
    DeploymentModel: 'PaaS'
    Environment: arrayOfNames[1]
    EnvironmentType: substring(arrayOfNames[1], 0, 3)
    Location: location
    Provider: 'Key Vault'
    'Resource Type': 'Vault'
    Service: arrayOfNames[3]
    ServiceGroup: arrayOfNames[0]
  }
  properties: {
    createMode: ((!empty(keyVaultId)) ? 'recover' : 'default')
    enableSoftDelete: keyVaultPurgeSoftDelete
    enablePurgeProtection: isPurgeProtectionEnabled
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    accessPolicies: ((!empty(keyVaultId)) ? json('null') : json('[]'))
    sku: {
      name: keyVaultSku
      family: 'A'
    }
    networkAcls: keyVaultNetworkAcls
  }
}

// resource keyVaultNameAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
//   parent: keyVault
//   name: 'add'
//   properties: {
//     accessPolicies: [for policy in keyVaultAccessPolicies: {
//       tenantId: policy.tenantId
//       objectId: policy.objectId
//       permissions: {
//         keys: policy.permissions.keys
//         secrets: policy.permissions.secrets
//         certificates: policy.permissions.certificates
//       }
//     }]
//   }
// }

// module keyVaultPrivateEndpoint 'keyVaultPrivateEndpoint.bicep' = if (deployPrivateEndpoints && (!empty(subnetName))) {
//   name: '${kvName}-privateEndpoint'
//   scope: resourceGroup(virtualNetworkResourceGroup)
//   params: {
//     arrayOfNames: arrayOfNames
//     keyVaultId: keyVault.id
//     location: location
//     privateEndpointName: privateEndpointName 
//     subnetId: subnetId
//     virtualNetworkId: virtualNetworkId
//   }
// }

output keyVaultName string = kvName
output privateEndpointName string = privateEndpointName
