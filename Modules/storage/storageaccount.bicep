//Parameters
param location string
param stNamePrefix string
param tags object

//Variables
var storageAccountName = '${stNamePrefix}${uniqueString(resourceGroup().id)}'
var accountType = 'Standard_LRS'
var kind = 'StorageV2'
var minimumTlsVersion = 'TLS1_2'
var supportsHttpsTrafficOnly = true
var allowBlobPublicAccess = false
var allowSharedKeyAccess = true
var networkAclsBypass = 'AzureServices'
var networkAclsDefaultAction = 'Deny'
var largeFileSharesState = 'Enabled'

//Deployment
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  tags: tags
  properties: {
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: []
    }
    largeFileSharesState: largeFileSharesState
  }
  sku: {
    name: accountType
  }
  kind: kind
}
