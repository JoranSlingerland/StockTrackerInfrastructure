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

//paramaters storage account
var stRg = resourceGroup(resourceGroupNames[2].name)
var stNamePrefix = 'st'


//parameters database
var sqlDatabaseRg = resourceGroup(resourceGroupNames[1].name)
param sqlDatabases array = [
  {
    name: 'sqldb-stocktracker-prod-westeu-001'
    dtu: 10
  }
]

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
    kvNamePrefix: kvNamePrefix
  }
  dependsOn: [
    resourceGroupsDeployment
  ]
}

module st 'Modules/storage/storageaccount.bicep' = {
  name: 'st'
  scope: stRg
  params: {
    tags: tags
    location: location
    stNamePrefix: stNamePrefix
  }
  dependsOn: [
    resourceGroupsDeployment
  ]
}
