//parameters
param cosmosdbNamePrefix string
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
var cosmosdbName = '${cosmosdbNamePrefix}${uniqueString(resourceGroup().id)}'

//resources
resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' = {
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
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
    capacity: {
      totalThroughputLimit: totalThroughputLimit
    }
  }
}
