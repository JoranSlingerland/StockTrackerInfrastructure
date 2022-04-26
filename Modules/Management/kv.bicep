//params
param kvName string
param location string
param tags object
param functionId string

@secure()
param COSMOSDB_ENDPOINT string
param COSMOSDB_DATABASE string
param COSMOSDB_OFFER_THROUGHPUT string
@secure()
param COSMOSDB_KEY string
@secure()
param apiKey string
@secure()
param CLEARBIT_API_KEY string

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
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: reference(functionId, '2019-08-01', 'full').identity.principalId
        permissions: {
          keys: []
          secrets: [
            'get'
          ]
          certificates: []
        }
      }
    ]
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
  }
}

resource kvServer 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'COSMOSDBENDPOINT'
  properties: {
    contentType: 'text/plain'
    value: COSMOSDB_ENDPOINT
  }
}

resource kvDatabase 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'COSMOSDBDATABASE'
  properties: {
    contentType: 'text/plain'
    value: COSMOSDB_DATABASE
  }
}

resource kvUser 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'COSMOSDBOFFERTHROUGHPUT'
  properties: {
    contentType: 'text/plain'
    value: COSMOSDB_OFFER_THROUGHPUT
  }
}

resource kvPassword 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'COSMOSDBKEY'
  properties: {
    contentType: 'text/plain'
    value: COSMOSDB_KEY
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

resource kvClearbit_api_key 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: kv
  name: 'CLEARBITAPIKEY'
  properties: {
    contentType: 'text/plain'
    value: CLEARBIT_API_KEY
  }
}
