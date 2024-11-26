param location string = resourceGroup().location
param appServicePlanName string = 'devious-asp-uat'
param appServiceAppName string
param appServiceAPIAppName string = 'devious-be-uat'
param appServiceAPIEnvVarENV string
param appServiceAPIEnvVarDBHOST string
param appServiceAPIEnvVarDBNAME string
@secure()
param appServiceAPIEnvVarDBPASS string
param appServiceAPIDBHostDBUSER string
param appServiceAPIDBHostFLASK_APP string
param appServiceAPIDBHostFLASK_DEBUG string
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'B1'

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier : 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAPIAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appSettings: [
        {
          name: 'ENV'
          value: appServiceAPIEnvVarENV
        }
        {
          name: 'DBHOST'
          value: appServiceAPIEnvVarDBHOST
        }
        {
          name: 'DBNAME'
          value: appServiceAPIEnvVarDBNAME
        }
        {
          name: 'DBPASS'
          value: appServiceAPIEnvVarDBPASS
        }
        {
          name: 'DBUSER'
          value: appServiceAPIDBHostDBUSER
        }
        {
          name: 'FLASK_APP'
          value: appServiceAPIDBHostFLASK_APP
        }
        {
          name: 'FLASK_DEBUG'
          value: appServiceAPIDBHostFLASK_DEBUG
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
      ]
    }
  }
}


resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: 'pm2 serve /home/site/wwwroot --spa --no-daemon'
      appSettings: []
    }
  }
}

resource appServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'AppServiceDiagnostics'
  scope: appServiceApp
  properties: {
    workspaceId: workspaceResourceId // Log Analytics Workspace ID
    logs: [
      {
        category: 'AppServiceHTTPLogs' // Captures HTTP logs
        enabled: true
      }
      {
        category: 'AppServiceConsoleLogs' // Captures console logs
        enabled: true
      }
      {
        category: 'AppServiceAppLogs' // Captures application logs
        enabled: true
      }
      {
        category: 'AppServiceAuditLogs' // Captures audit logs
        enabled: true
      }
      {
        category: 'AppServiceIPSecAuditLogs' // Captures IPSec audit logs
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs' // Captures platform logs
        enabled: true
      }
      {
        category: 'AppServiceAuthenticationLogs' // Captures authentication logs
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics' // Tracks all metrics for the app service
        enabled: false
      }
    ]
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName

