//parameters
param cosmosdbName string
param location string
param tags object
param cosmosdbFreeTierOffer bool
param totalThroughputLimit int

//variables
var locations = [
  {
    locationName: location
    failoverPriority: 0
    isZoneRedundant: false
  }
]

//resources
resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2022-11-15' = {
  name: cosmosdbName
  location: location
  kind: 'GlobalDocumentDB'
  tags: tags
  properties: {
    publicNetworkAccess: 'enabled'
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
    }
    capacity: {
      totalThroughputLimit: totalThroughputLimit
    }
    networkAclBypass: 'AzureServices'
    minimalTlsVersion: 'Tls12'
    ipRules: []
  }
}

var COSMOSDB_ENDPOINT = 'https://${cosmosdbName}.documents.azure.com:443'
var COSMOSDB_KEY = cosmosdb.listKeys().primaryMasterKey

output COSMOSDB_ENDPOINT string = COSMOSDB_ENDPOINT
output COSMOSDB_KEY string = COSMOSDB_KEY
