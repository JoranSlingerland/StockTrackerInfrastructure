// generic parameters
targetScope = 'subscription'
param location string = 'westeurope'
param resourceGroupNames array = [
  {
    name:'rg-mgmt-prod-westeu-001'
    lockResourceGroup: false
  }
  {
    name:'rg-sql-prod-westeu-001'
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

//parameters sql server
var sqlServerRg = resourceGroup(resourceGroupNames[1].name)
param sqlServerName string = 'sql-stocktracker-prod-westeu-001'
param localAdminUsername string = 'azadmin'
@secure()
param localAdminPassword string

//paramters keyvault
var kvRg = resourceGroup(resourceGroupNames[0].name)
param kvNamePrefix string = 'kv-'

@secure()
param server string
@secure()
param database string
@secure()
param apiKey string

//Paramters Function
var functionRg = resourceGroup(resourceGroupNames[2].name)
var appServicePlanNamePrefix = 'plan-'
var functionNamePrefix = 'func-'
var stNamePrefix = 'st'

//parameters database
var sqlDatabaseRg = resourceGroup(resourceGroupNames[1].name)
param sqlDatabases array = [
  {
    name: 'sqldb-stocktracker-prod-westeu-001'
    dtu: 10
  }
]

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

module resourceGroupsDeployment './Modules/Management/resourcegroups.bicep' = {
  name: 'resourceGroupDeployment'
  params: {
    location: location
    resourceGroupNames: resourceGroupNames
    tags: tags
  } 
}

module sqlServer './Modules/SQL/sqlserver.bicep' = {
  name: 'sqlServer'
  scope: sqlServerRg
  params: {
    tags: tags
    location: location
    administratorLogin: localAdminUsername
    administratorLoginPassword: localAdminPassword
    serverName: sqlServerName
  }
  dependsOn: [
    resourceGroupsDeployment
  ]
}

module sqlDatabase './Modules/SQL/sqldatabase.bicep' = {
  name: 'sqlDatabase'
  scope: sqlDatabaseRg
  params: {
    tags: tags
    location: location
    sqlServerName: sqlServerName
    sqlDatabases: sqlDatabases
  }
  dependsOn: [
    sqlServer
    resourceGroupsDeployment
  ]
}

module kvName 'Modules/Management/kvName.bicep' = {
  name: 'kvName'
  scope: kvRg
  params: {
    kvNamePrefix: kvNamePrefix
  }
}

module kv 'Modules/Management/kv.bicep' = {
  name: 'kv'
  scope: kvRg
  params: {
    tags: tags
    location: location
    apiKey: apiKey
    server: server
    database: database
    password: localAdminPassword
    user: localAdminUsername
    kvName: kvName.outputs.kvNameOutput
    functionId: function.outputs.functionId
  }
  dependsOn: [
    resourceGroupsDeployment
    kvName
    function
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
    kvName: kvName.outputs.kvNameOutput
    appInsightsInstrumentationKey: ai.outputs.appInsightsInstrumentationKey
  }
  dependsOn: [
    resourceGroupsDeployment
    kvName
    ai
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
