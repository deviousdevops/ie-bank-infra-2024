param location string = resourceGroup().location
param name string  

@allowed([
  'web'
  'other'
])
param applicationType string = 'web'
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string = 

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

resource loginSLOAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Login-SLO-Alert'
  location: 'global'
  properties: {
    description: 'Alert when login response time exceeds 2 seconds'
    severity: 2
    enabled: true
    scopes: [
      appInsights.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'LoginResponseTime'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'requests/duration'
          operator: 'GreaterThan'
          threshold: 1000
          timeAggregation: 'Average'
        }
      ]
    }
  }
}

output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsId string = appInsights.id
