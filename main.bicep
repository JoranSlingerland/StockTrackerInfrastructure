//resources to deploy
param deployResoucegroups bool = true
param deploySqlServer bool = true

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

//sql server parameters
//parameters sql server
var sqlServerRg = resourceGroup(resourceGroupNames[1].name)
param sqlServerName string = 'sql-apps-prod-westeu-055'
param localAdminUsername string = 'azadmin'
@secure()
param localAdminPassword string

module resourceGroupsDeployment './Modules/Management/resourcegroups.bicep' = if (deployResoucegroups){
  name: 'resourceGroupDeployment'
  params: {
    location: location
    resourceGroupNames: resourceGroupNames
    tags: tags
  } 
}

module sqlServer './Modules/sql/sqlserver.bicep' = if (deploySqlServer) {
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
