param swaNamePrefix string
param location string
param gitRepo string
param tags object
@secure()
param repositoryToken string

var swaName = '${swaNamePrefix}${uniqueString(resourceGroup().id)}'

resource swa 'Microsoft.Web/staticSites@2021-03-01' = {
  name: swaName
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
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
