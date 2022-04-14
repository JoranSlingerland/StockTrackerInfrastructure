//parameters
param appInsightsNamePrefix string
param location string
param laId string
param tags object

//variables
var appInsightsName = '${appInsightsNamePrefix}${uniqueString(resourceGroup().id)}'

//resources
resource appInsights 'microsoft.insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
    WorkspaceResourceId: laId
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  tags: tags
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
