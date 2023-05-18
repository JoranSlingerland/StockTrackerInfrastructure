//parameters
param cosmosdbName string
param location string
param tags object
param cosmosdbFreeTierOffer bool
param totalThroughputLimit int
param COSMOSDB_DATABASE string

//variables
var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

var containers = [
  {
    name: 'input_invested'
    partitionKeyPath: '/id'
  }
  {
    name: 'input_transactions'
    partitionKeyPath: '/id'
  }
  {
    name: 'meta_data'
    partitionKeyPath: '/id'
  }
  {
    name: 'stocks_held'
    partitionKeyPath: '/id'
  }
  {
    name: 'totals'
    partitionKeyPath: '/id'
  }
  {
    name: 'users'
    partitionKeyPath: '/id'
  }
]

//resources
resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: cosmosdbName
  location: location
  kind: 'GlobalDocumentDB'
  tags: tags
  properties: {
    publicNetworkAccess: 'Enabled'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    enableFreeTier: cosmosdbFreeTierOffer
    enableAnalyticalStorage: false
    analyticalStorageConfiguration: {
      schemaType: 'WellDefined'
    }
    databaseAccountOfferType: 'Standard'
    locations: locations
    backupPolicy: {
      type: 'Continuous'
      continuousModeProperties: {
        tier: 'Continuous7Days'
      }
    }
    capacity: {
      totalThroughputLimit: totalThroughputLimit
    }
    networkAclBypass: 'AzureServices'
    minimalTlsVersion: 'Tls12'
    ipRules: [ {
        ipAddressOrRange: '0.0.0.0'
      } ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  name: COSMOSDB_DATABASE
  location: location
  parent: cosmosdb
  properties: {
    resource: {
      id: COSMOSDB_DATABASE
    }
  }
}

resource databaseThroughput 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/throughputSettings@2023-04-15' = {
  name: 'default'
  location: location
  parent: database
  properties: {
    resource: {
      autoscaleSettings: {
        maxThroughput: totalThroughputLimit
      }
      throughput: totalThroughputLimit
    }
  }
}

resource dbContainers 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = [for container in containers: {
  name: container.name
  location: location
  parent: database
  properties: {
    resource: {
      conflictResolutionPolicy: {
        conflictResolutionPath: '/_ts'
        mode: 'LastWriterWins'
      }
      id: container.name
      indexingPolicy: {
        automatic: true
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
        includedPaths: [
          {
            path: '/*'
          }
        ]
        indexingMode: 'consistent'
      }
      partitionKey: {
        kind: 'Hash'
        paths: [
          container.partitionKeyPath
        ]
        version: 2
      }
    }
  }
  dependsOn: [
    databaseThroughput
  ]
}]

var COSMOSDB_ENDPOINT = 'https://${cosmosdbName}.documents.azure.com:443'
var COSMOSDB_KEY = cosmosdb.listKeys().primaryMasterKey

output COSMOSDB_ENDPOINT string = COSMOSDB_ENDPOINT
output COSMOSDB_KEY string = COSMOSDB_KEY
