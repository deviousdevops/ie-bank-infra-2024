param location string
param serverName string
param databaseName string
param postgreSQLAdminServicePrincipalObjectId string
param postgreSQLAdminServicePrincipalName string
param workspaceResourceId string
param administratorLogin string
@secure()
param administratorLoginPassword string

var sku = {
  name: 'Standard_B1ms'
  tier: 'Burstable'
}

resource postgresqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: toLower(replace(serverName, '_', '-'))
  location: location
  sku: sku
  properties: {
    version: '15'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Enabled'
      tenantId: subscription().tenantId
    }
  }
}

resource firewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = {
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  parent: postgresqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgreSQLAdministrators 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2022-12-01' = {
  parent: postgresqlServer
  name: postgreSQLAdminServicePrincipalObjectId
  properties: {
    principalName: postgreSQLAdminServicePrincipalName
    principalType: 'ServicePrincipal'
    tenantId: subscription().tenantId
  }
  dependsOn: [
    firewallRule
  ]
}

resource postgreSQLDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'PostgreSQLServerDiagnostic'
  scope: postgresqlServer
  properties: {
    workspaceId: workspaceResourceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'PostgreSQLLogs'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexSessions'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexQueryStoreRuntime'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexQueryStoreWaitStats'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexTableStats'
        enabled: true
      }
      {
        category: 'PostgreSQLFlexDatabaseXacts'
        enabled: true
      }
    ]
  }
}

resource queryPerformanceAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'Failed-Connections-Alert'
  location: 'global'
  properties: {
    description: 'Alert when there are failed connections'
    severity: 2
    enabled: true
    scopes: [
      postgresqlServer.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Connections-Failed'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'connections_failed'
          operator: 'GreaterThan'
          threshold: 1
          timeAggregation: 'Total'
        }
      ]
    }
  }
}

output postgresqlServerFqdn string = postgresqlServer.properties.fullyQualifiedDomainName
output databaseName string = databaseName
output serverId string = postgresqlServer.id
output serverName string = postgresqlServer.name
