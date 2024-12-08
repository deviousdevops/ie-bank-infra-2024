param logicAppEndpoint string
param appInsightsId string
param appServicePlanId string
param webAppId string

// Create Action Group for Logic App
resource actionGroup 'Microsoft.Insights/actionGroups@2019-06-01' = {
  name: 'devious-alerts-action-group'
  location: 'global'
  properties: {
    groupShortName: 'SlackAlert'
    enabled: true
    webhookReceivers: [
      {
        name: 'SlackWebhook'
        serviceUri: logicAppEndpoint
        useCommonAlertSchema: true
      }
    ]
  }
}

// Alert 1: Login Response Time
resource loginResponseTimeAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Login-Response-Time-Alert'
  location: 'global'
  properties: {
    description: 'Alert when login response time exceeds 2 seconds'
    severity: 2
    enabled: true
    scopes: [
      appInsightsId
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
          threshold: 2000
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Alert 2: CPU Usage
resource cpuUsageAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'CPU-Usage-Alert'
  location: 'global'
  properties: {
    description: 'Alert when CPU usage exceeds 80%'
    severity: 2
    enabled: true
    scopes: [
      appServicePlanId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'CPUUsage'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'CpuPercentage'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

// Alert 3: HTTP Error Rate
resource httpErrorRateAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'HTTP-Error-Rate-Alert'
  location: 'global'
  properties: {
    description: 'Alert when HTTP error rate exceeds 1%'
    severity: 2
    enabled: true
    scopes: [
      webAppId
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'HTTPErrors'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'Http4xx'
          operator: 'GreaterThan'
          threshold: 1
          timeAggregation: 'Total'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
} 
