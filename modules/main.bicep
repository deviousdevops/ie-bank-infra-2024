param location string = resourceGroup().location

// Deploy Log Analytics Workspace
module logAnalytics './modules/log-analytics.bicep' = {
  name: 'logAnalyticsDeployment'
  params: {
    location: location
  }
}

// Deploy Application Insights and link it to the Log Analytics Workspace
module appInsights './modules/app-insights.bicep' = {
  name: 'appInsightsDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
}

// Deploy Workbook linked to Application Insights
module workbook './modules/workbook.bicep' = {
  name: 'workbookDeployment'
  params: {
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    appInsightsId: appInsights.outputs.connectionString
  }
}
