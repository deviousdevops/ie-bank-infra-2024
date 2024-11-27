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
param appServiceAppHostName string

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

resource appInsightsAvailabilityTest 'Microsoft.Insights/webtests@2022-06-15' = {
  name: '${name}-login-test'
  location: location
  tags: {
    'hidden-link:${appInsights.id}': 'Resource'
  }
  properties: {
    Name: 'Login Response Time Test'
    Description: 'Monitors login endpoint response time'
    Enabled: true
    Frequency: 300
    Timeout: 120
    Kind: 'ping'
    RetryEnabled: true
    Locations: [
      {
        Id: 'emea-nl-ams-azr'
      }
    ]
    Configuration: {
      WebTest: '''
        <WebTest Name="Login Response Time Test" Id="${guid(name)}" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="120" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
          <Items>
            <Request Method="POST" Version="1.1" Url="https://${appServiceAppHostName}/api/login" ThinkTime="0" Timeout="120" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
          </Items>
        </WebTest>
      '''
    }
    SyntheticMonitorId: '${name}-login-test'
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
