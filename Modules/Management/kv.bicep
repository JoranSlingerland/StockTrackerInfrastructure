//params
param kvNamePrefix string
param location string
param tags object

@secure()
param server string
@secure()
param database string
@secure()
param user string
@secure()
param password string
@secure()
param apiKey string

var kvName = '${kvNamePrefix}${uniqueString(resourceGroup().id)}'

//resources
resource kv 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: kvName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
    //   {
    //     tenantId: subscription().tenantId
    //     objectId: reference(funcAppName.id, '2019-08-01', 'full').identity.principalId
    //     permissions: {
    //       keys: []
    //       secrets: [
    //         'get'
    //       ]
    //       certificates: []
    //     }
    //   }
    //]
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: false
    enablePurgeProtection: false
  }
}

resource kvServer 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'server'
  properties: {
    contentType: 'text/plain'
    value: server
  }
}

resource kvDatabase 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'database'
  properties: {
    contentType: 'text/plain'
    value: database
  }
}

resource kvUser 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'user'
  properties: {
    contentType: 'text/plain'
    value: user
  }
}

resource kvPassword 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'password'
  properties: {
    contentType: 'text/plain'
    value: password
  }
}

resource kvApi_key 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'apikey'
  properties: {
    contentType: 'text/plain'
    value: apiKey
  }
}
