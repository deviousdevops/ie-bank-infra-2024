param location string = resourceGroup().location
param name string
@allowed(['nonprod', 'prod'])
param environmentType string
param retentionDays int = (environmentType == 'prod') ? 90 : 30

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: retentionDays
  }
}

output logAnalyticsWorkspaceId string = logAnalytics.id

