param location string = resourceGroup().location
param name string
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
param environmentType string 

param retentionDays int = (environmentType == 'prod') ? 90 : 30

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: applicationType
  tags: {
    environment: environmentType
  }
  properties: {
    Application_Type: applicationType
    RetentionInDays: retentionDays
    IngestionMode: 'ApplicationInsights'
    publicNetworkAccessForIngestion: 'Enabled' // Allow data ingestion from public networks
    publicNetworkAccessForQuery: 'Enabled'    // Allow queries from public networks
  }
}

// Outputs for integration with other services
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString

