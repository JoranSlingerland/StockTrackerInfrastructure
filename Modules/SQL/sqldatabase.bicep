//Parameters
param sqlServerName string
param location string
param sqlDatabases array
param tags object

//Deployment
@batchSize(2)
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-02-01-preview' = [for database in sqlDatabases: {
  name: '${sqlServerName}/${database.Name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: database.dtu
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 268435456000
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Geo'
    maintenanceConfigurationId: '/subscriptions/6632c3ab-c4fa-4d1e-956e-66bd7e515d44/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
  }
}]

resource auditingPolicy 'Microsoft.Sql/servers/databases/auditingPolicies@2014-04-01' = [for (database, i) in sqlDatabases: {
  parent: sqlDatabase[i]
  name: 'Default'
  properties: {
    auditingState: 'Disabled'
  }
}]

resource longTermRetention 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2017-03-01-preview' = [for (database, i) in sqlDatabases: {
  parent: sqlDatabase[i]
  name: 'Default'
  properties: {
    weeklyRetention: 'PT0S'
    monthlyRetention: 'PT0S'
    yearlyRetention: 'PT0S'
    weekOfYear: 1
  }
  dependsOn: [
    auditingPolicy[i]
  ]
}]

resource shortTermRetention 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2017-10-01-preview' = [for (database, i) in sqlDatabases: {
  parent: sqlDatabase[i]
  name: 'Default'
  properties: {
    retentionDays: 7
  }
  dependsOn: [ 
    longTermRetention[i]
  ]
}]

resource geoBackupPolicy 'Microsoft.Sql/servers/databases/geoBackupPolicies@2014-04-01' = [for (database, i) in sqlDatabases: {
  parent: sqlDatabase[i]
  name: 'Default'
  properties: {
    state: 'Enabled'
  }
  dependsOn: [
    shortTermRetention[i]
  ]
}]

resource encryption 'Microsoft.Sql/servers/databases/transparentDataEncryption@2014-04-01' = [for (database, i) in sqlDatabases: {
  parent: sqlDatabase[i]
  name: 'current'
  properties: {
    status: 'Enabled'
  }
  dependsOn: [
    geoBackupPolicy[i]
  ]
}]
