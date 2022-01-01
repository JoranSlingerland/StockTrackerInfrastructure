//Parameters
param administratorLogin string
@secure()
param administratorLoginPassword string
param location string
param serverName string
param enableADS bool = false
param allowAzureIps bool = true
param tags object

//Deployment
resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    version: '12.0'
  }
}

resource allowAzureResources 'Microsoft.Sql/servers/firewallRules@2014-04-01-preview' = if (allowAzureIps) {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  location: location
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource alerts 'Microsoft.Sql/servers/securityAlertPolicies@2017-03-01-preview' = if (enableADS) {
  parent: sqlServer
  name: 'Default'
  properties: {
    state: 'Enabled'
    emailAccountAdmins: true
  }
}
