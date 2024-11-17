param location string = resourceGroup().location
param name string
param applicationType string = 'web'
param environmentType string
@allowed(['nonprod', 'prod'])
param retentionDays int = (environmentType == 'prod') ? 90 : 30

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: applicationType
  properties: {
    Application_Type: applicationType
    retentionInDays: retentionDays
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
