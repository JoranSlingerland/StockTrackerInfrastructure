//resources to deploy
param deployResoucegroups bool = true

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

module resourceGroupsDeployment '.\\Modules\\Management\\resourcegroup.bicep' = if (deployResoucegroups){
  name: 'resourceGroupDeployment'
  params: {
    location: location
    resourceGroupNames: resourceGroupNames
    tags: tags
  } 
}
