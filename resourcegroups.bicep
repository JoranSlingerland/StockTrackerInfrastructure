//Scope
targetScope = 'subscription'

//Paramters
param resourceGroupNames array
param location string
param tags object

//Deployment
@batchSize(2)
resource resourceGroupDeployment 'Microsoft.Resources/resourceGroups@2021-04-01' = [for (resourceGroupName, i) in resourceGroupNames: {
  name: resourceGroupName.name
  location: location
  tags: tags
  properties: {
  }
}]

module deployRgLock './lockrg.bicep' = [for (resourceGroupName, i) in resourceGroupNames: if (resourceGroupNames[i].lockResourceGroup) {
  name: 'lockDeployment'
  scope: resourceGroup(resourceGroupName.name)
  dependsOn:[
    resourceGroupDeployment[i]
  ]
}]
