// generic parameters
targetScope = 'subscription'
param location string = 'westeurope'
param resourceGroupNames array = [
  {
    name: 'rg-mgmt-prod-westeu-001'
    lockResourceGroup: false
  }
  {
    name: 'rg-sql-prod-westeu-001'
    lockResourceGroup: false
  }
  {
    name: 'rg-func-prod-westeu-001'
    lockResourceGroup: false
  }
]

//tags
param basetime string = utcNow('u')
param tags object = {
  'env': 'prod'
  'utcdatedeployed': basetime
  'project': 'Stocktracker'
  'deployment_type': 'Bicep'
}

//paramters keyvault
var kvRg = resourceGroup(resourceGroupNames[0].name)
param kvNamePrefix string = 'kv-'

param cosmosdbLocation string = 'westus'
param COSMOSDB_DATABASE string = 'stocktracker'
param COSMOSDB_OFFER_THROUGHPUT string = '1000'
@secure()
param apiKey string
@secure()
param CLEARBIT_API_KEY string

//Paramters Function
var functionRg = resourceGroup(resourceGroupNames[2].name)
var appServicePlanNamePrefix = 'plan-'
var functionNamePrefix = 'func-'
var stNamePrefix = 'st'

//Log analytics parameters
var logAnalyticsRg = resourceGroup(resourceGroupNames[0].name)
param logAnalyticsNamePrefix string = 'la-'
param logAnalyticsWorkspaceSku string = 'PerGB2018'

//App Insights parameters
var appInsightsRg = resourceGroup(resourceGroupNames[0].name)
param appInsightsNamePrefix string = 'ai-'

//Static web app parameters
var swaRg = resourceGroup(resourceGroupNames[2].name)
param swaNamePrefix string = 'swa-'
param swaGitRepo string = 'https://github.com/JoranSlingerland/Stocktracker-FrontEnd'
@secure()
param repositoryToken string

//cosmos db parameters
var cosmosdbRg = resourceGroup(resourceGroupNames[1].name)
param cosmosdbNamePrefix string = 'cosmosdb-'
param cosmosdbFreeTierOffer bool = true
param cosmosdbTotalThroughputLimit int = 1000

module resourceGroupsDeployment './Modules/Management/resourcegroups.bicep' = {
  name: 'resourceGroupDeployment'
  params: {
    location: location
    resourceGroupNames: resourceGroupNames
    tags: tags
  }
}

module kvName 'Modules/Management/nameGeneration.bicep' = {
  name: 'kvName'
  scope: kvRg
  params: {
    namePrefix: kvNamePrefix
  }
}

module cosmosdbName 'Modules/Management/nameGeneration.bicep' = {
  name: 'cosmosdbName'
  scope: cosmosdbRg
  params: {
    namePrefix: cosmosdbNamePrefix
  }
}

module kv 'Modules/Management/kv.bicep' = {
  name: 'kv'
  scope: kvRg
  params: {
    tags: tags
    location: location
    apiKey: apiKey
    COSMOSDB_ENDPOINT: cosmos.outputs.COSMOSDB_ENDPOINT
    COSMOSDB_DATABASE: COSMOSDB_DATABASE
    COSMOSDB_OFFER_THROUGHPUT: COSMOSDB_OFFER_THROUGHPUT
    COSMOSDB_KEY: cosmos.outputs.COSMOSDB_KEY
    CLEARBIT_API_KEY: CLEARBIT_API_KEY
    kvName: kvName.outputs.nameOutput
    functionId: function.outputs.functionId
  }
  dependsOn: [
    resourceGroupsDeployment
    kvName
    function
    cosmos
  ]
}

module function 'Modules/functions/function.bicep' = {
  name: 'function'
  scope: functionRg
  params: {
    tags: tags
    location: location
    stNamePrefix: stNamePrefix
    appServicePlanNamePrefix: appServicePlanNamePrefix
    functionNamePrefix: functionNamePrefix
    kvName: kvName.outputs.nameOutput
    appInsightsInstrumentationKey: ai.outputs.appInsightsInstrumentationKey
  }
  dependsOn: [
    resourceGroupsDeployment
    kvName
    ai
    cosmos
  ]
}

module la 'Modules/Management/logAnalytics.bicep' = {
  name: 'la'
  scope: logAnalyticsRg
  params: {
    tags: tags
    location: location
    logAnalyticsNamePrefix: logAnalyticsNamePrefix
    logAnalyticsWorkspaceSku: logAnalyticsWorkspaceSku
  }
  dependsOn: [
    resourceGroupsDeployment
  ]
}

module ai 'Modules/Management/appInsights.bicep' = {
  name: 'ai'
  scope: appInsightsRg
  params: {
    tags: tags
    location: location
    appInsightsNamePrefix: appInsightsNamePrefix
    laId: la.outputs.laId
  }
  dependsOn: [
    resourceGroupsDeployment
    la
  ]
}

module swa 'Modules/functions/swa.bicep' = {
  name: 'swa'
  scope: swaRg
  params: {
    tags: tags
    location: location
    swaNamePrefix: swaNamePrefix
    gitRepo: swaGitRepo
    repositoryToken: repositoryToken
  }
  dependsOn: [
    resourceGroupsDeployment
  ]
}

module cosmos 'Modules/cosmosdb.bicep' = {
  name: 'cosmos'
  scope: cosmosdbRg
  params: {
    tags: tags
    location: cosmosdbLocation
    cosmosdbFreeTierOffer: cosmosdbFreeTierOffer
    cosmosdbName: cosmosdbName.outputs.nameOutput
    totalThroughputLimit: cosmosdbTotalThroughputLimit
  }
  dependsOn: [
    resourceGroupsDeployment
    cosmosdbName
  ]
}
