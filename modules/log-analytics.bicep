@description('Module to deploy a Log Analytics Workspace with configurable retention days based on environment type')
param location string = resourceGroup().location
param name string
@allowed(['nonprod', 'prod'])
param environmentType string
param retentionDays int = (environmentType == 'prod') ? 90 : 30

// Define the Log Analytics Workspace resource
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

// Output the Log Analytics Workspace ID
output logAnalyticsWorkspaceId string = logAnalytics.id
