//resources to deploy
param deployResoucegroups bool = true
param deploySqlServer bool = true
param deploySqlDatabases bool = true

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
}

//parameters sql server
var sqlServerRg = resourceGroup(resourceGroupNames[1].name)
param sqlServerName string = 'sql-stocktracker-prod-westeu-001'
param localAdminUsername string = 'azadmin'
@secure()
param localAdminPassword string

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
