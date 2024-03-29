//paramas
param location string
param appServicePlanNamePrefix string
param functionNamePrefix string
param stNamePrefix string
param tags object
param kvName string
param appInsightsInstrumentationKey string

//variables
var appServicePlanName = '${appServicePlanNamePrefix}${uniqueString(resourceGroup().id)}'
var functionName = '${functionNamePrefix}${uniqueString(resourceGroup().id)}'
var storageAccountName = '${stNamePrefix}${uniqueString(resourceGroup().id)}'
var accountType = 'Standard_LRS'
var kind = 'StorageV2'

//resouces
resource functionSite 'Microsoft.Web/sites@2021-03-01' = {
  identity: {
    type: 'SystemAssigned'
  }
  name: functionName
  location: location
  kind: 'functionapp,linux'
  tags: tags
  properties: {
    hostNameSslStates: [
      {
        name: '${functionName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    enabled: true
    serverFarmId: appServicePlan.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'functionTimeout'
          value: '00:10:00'
        }
        {
          name: 'ENABLE_ORYX_BUILD'
          value: '1'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: '1'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'COSMOSDB_ENDPOINT'
          value: '@Microsoft.KeyVault(SecretUri=https://${kvName}.vault.azure.net/secrets/COSMOSDBENDPOINT)'
        }
        {
          name: 'COSMOSDB_DATABASE'
          value: '@Microsoft.KeyVault(SecretUri=https://${kvName}.vault.azure.net/secrets/COSMOSDBDATABASE)'
        }
        {
          name: 'COSMOSDB_KEY'
          value: '@Microsoft.KeyVault(SecretUri=https://${kvName}.vault.azure.net/secrets/COSMOSDBKEY)'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
      ]
      numberOfWorkers: 1
      linuxFxVersion: 'Python|3.10'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '61AE8477F2145B6AF7100EEC8FD3FFCFB4702811C04010012621EA24BBB80944'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2018-02-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  tags: tags
  properties: {}
  sku: {
    name: accountType
  }
  kind: kind
}

output functionId string = functionSite.id
