param location string = resourceGroup().location
param workbookName string = 'zaidgroup-workbook-uat'
param logAnalyticsWorkspaceId string
param appInsightsId string

resource workbook 'Microsoft.Insights/workbooks@2020-10-20' = {
  name: workbookName
  location: location
  properties: {
    displayName: 'BestBank Monitoring Workbook'
    category: 'workbooks'
    sourceId: appInsightsId
    version: '1.0'
    serializedData: '{"version":"Notebook/1.0","items":[{"type":1,"content":{"json":"{\"chartName\":\"HTTP Requests\",\"query\":\"requests | summarize count() by bin(timestamp, 5m)\",\"size\":1}}]}'
  }
}

output workbookLink string = workbook.id
