//parameters
param location string
param logAnalyticsNamePrefix string
param logAnalyticsWorkspaceSku string
param tags object

var logAnalyticsWorkspaceName = '${logAnalyticsNamePrefix}${uniqueString(resourceGroup().id)}'

//Deployment
//Create Log Analytics Workspace
resource la 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name : logAnalyticsWorkspaceName
  location : location
  tags: tags
  properties : {
    sku: {
      name : logAnalyticsWorkspaceSku
    }
  }
}

output laId string = la.id
