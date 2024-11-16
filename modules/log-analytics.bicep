param location string = resourceGroup().location
param logAnalyticsWorkspaceName string = 'bestbank-log-uat'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: 90
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
