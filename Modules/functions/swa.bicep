//parameters
param swaNamePrefix string
param location string
param gitRepo string
param tags object
@secure()
param repositoryToken string
param backendResourceId string

//variables
var swaName = '${swaNamePrefix}${uniqueString(resourceGroup().id)}'

//resources
resource swa 'Microsoft.Web/staticSites@2021-03-01' = {
  name: swaName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    repositoryUrl: gitRepo
    branch: 'main'
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'GitHub'
    enterpriseGradeCdnStatus: 'Disabled'
    repositoryToken: repositoryToken
    buildProperties: {
      appLocation: '/'
      outputLocation: 'out'
    }
  }
  tags: tags
}

resource backend 'Microsoft.Web/staticSites/linkedBackends@2022-03-01' = {
  name: 'api'
  parent: swa
  properties: {
    backendResourceId: backendResourceId
    region: location
  }
}
