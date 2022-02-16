//resources to deploy
param deployResoucegroups bool = true
param deploySqlServer bool = true
param deploySqlDatabases bool = true
param deployKv bool = true

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
param api_key string


//parameters database
var sqlDatabaseRg = resourceGroup(resourceGroupNames[1].name)
param sqlDatabases array = [
  {
    name: 'sqldb-stocktracker-prod-westeu-001'
    dtu: 10
  }
]

module resourceGroupsDeployment './Modules/Management/resourcegroups.bicep' = if (deployResoucegroups){
  name: 'resourceGroupDeployment'
  params: {
    location: location
    resourceGroupNames: resourceGroupNames
    tags: tags
  } 
}

module sqlServer './Modules/SQL/sqlserver.bicep' = if (deploySqlServer) {
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

module sqlDatabase './Modules/SQL/sqldatabase.bicep' = if (deploySqlDatabases){
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

module kv 'Modules/Management/kv.bicep' = if (deployKv){
  name: 'kv'
  scope: kvRg
  params: {
    tags: tags
    location: location
    api_key: api_key
    server: server
    database: database
    password: localAdminPassword
    user: localAdminUsername
    kvNamePrefix: kvNamePrefix
  }
}
