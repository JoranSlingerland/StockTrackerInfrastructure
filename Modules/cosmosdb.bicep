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

var COSMOSDB_ENDPOINT = 'https://${cosmosdbName}.documents.azure.com:443'
var COSMOSDB_KEY = cosmosdb.listKeys().primaryMasterKey

output COSMOSDB_ENDPOINT string = COSMOSDB_ENDPOINT
output COSMOSDB_KEY string = COSMOSDB_KEY
