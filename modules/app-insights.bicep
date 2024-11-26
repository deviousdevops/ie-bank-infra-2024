param location string = resourceGroup().location
param name string = 'devious-ai-uat'

@allowed([
  'web'
  'other'
])
param applicationType string = 'web'
@allowed([
  'nonprod'
  'prod'
  'uat'
])
param environmentType string = 'uat'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  tags: {
    environment: environmentType
  }
  properties: {
    Application_Type: applicationType
    RetentionInDays: (environmentType == 'prod') ? 90 : 30
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
