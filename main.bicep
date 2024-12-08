@sys.description('The environment type (nonprod or prod)')
@allowed([
  'dev'
  'uat'
  'prod'
])
param environmentType string 
@sys.description('The user alias to add to the deployment name')
param userAlias string = 'deviousinc'
@sys.description('The PostgreSQL Server name')
@minLength(3)
@maxLength(24)
param postgreSQLServerName string 
@sys.description('The PostgreSQL Database name')
@minLength(3)
@maxLength(24)
param postgreSQLDatabaseName string 
@sys.description('The App Service Plan name')
@minLength(3)
@maxLength(24)
param appServicePlanName string 
@sys.description('The Web App name (frontend)')
@minLength(3)
@maxLength(24)
param appServiceAppName string 
@sys.description('The API App name (backend)')
@minLength(3)
@maxLength(24)
param appServiceAPIAppName string 
@sys.description('The Azure location where the resources will be deployed')
param location string = resourceGroup().location
@sys.description('The value for the environment variable ENV')
param appServiceAPIEnvVarENV string
@sys.description('The value for the environment variable DBHOST')
param appServiceAPIEnvVarDBHOST string
@sys.description('The value for the environment variable DBNAME')
param appServiceAPIEnvVarDBNAME string
@sys.description('The value for the environment variable DBPASS')
@secure()
param appServiceAPIEnvVarDBPASS string
@sys.description('The value for the environment variable DBUSER')
param appServiceAPIDBHostDBUSER string
@sys.description('The value for the environment variable FLASK_APP')
param appServiceAPIDBHostFLASK_APP string
@sys.description('The value for the environment variable FLASK_DEBUG')
param appServiceAPIDBHostFLASK_DEBUG string
@secure()
param appServiceAPISecretKey string
param keyVaultName string
param containerRegistryName string
param applicationInsightsName string
param logAnalyticsWorkspaceName string
param staticWebAppName string
param postgreSQLAdminServicePrincipalObjectId string
param postgreSQLAdminServicePrincipalName string
param githubActionsPrincipalId string
@secure()
param slackWebhookUrl string
param logicAppName string
@secure()
param appInsightsConnectionString string
param appInsightsInstrumentationKey string


module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    name: applicationInsightsName
    environmentType: environmentType
  }
  dependsOn: [
    appService
  ]
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    name: logAnalyticsWorkspaceName
    environmentType: environmentType
  }
}

module containerRegistry 'modules/docker-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    name: containerRegistryName
    sku: 'Standard'
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    githubActionsPrincipalId: githubActionsPrincipalId
    backendAppServicePrincipalId: githubActionsPrincipalId
  }
  dependsOn: [
    logAnalytics
  ]
}

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    name: keyVaultName
    adminPassword: appServiceAPIEnvVarDBPASS
    registryName: containerRegistryName
    objectId: subscription().subscriptionId
    githubActionsPrincipalId: githubActionsPrincipalId
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    containerRegistry
    logAnalytics 
  ]
}

module postgresql 'modules/postgresql-db.bicep' = {
  name: 'postgresql-deployment'
  params: {
    location: location
    serverName: postgreSQLServerName
    databaseName: postgreSQLDatabaseName
    postgreSQLAdminServicePrincipalObjectId: postgreSQLAdminServicePrincipalObjectId
    postgreSQLAdminServicePrincipalName: postgreSQLAdminServicePrincipalName
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    administratorLogin: appServiceAPIDBHostDBUSER
    administratorLoginPassword: appServiceAPIEnvVarDBPASS
  }
  dependsOn: [
    logAnalytics
  ]
}

module appService 'modules/app-service.bicep' = {
  name: 'appService-${userAlias}'
  params: {
    location: location
    environmentType: environmentType
    appServiceAppName: appServiceAppName
    appServiceAPIAppName: appServiceAPIAppName
    appServicePlanName: appServicePlanName
    appServiceAPIDBHostDBUSER: appServiceAPIDBHostDBUSER
    appServiceAPIDBHostFLASK_APP: appServiceAPIDBHostFLASK_APP
    appServiceAPIDBHostFLASK_DEBUG: appServiceAPIDBHostFLASK_DEBUG
    appServiceAPIEnvVarDBHOST: appServiceAPIEnvVarDBHOST
    appServiceAPIEnvVarDBNAME: appServiceAPIEnvVarDBNAME
    appServiceAPIEnvVarDBPASS: appServiceAPIEnvVarDBPASS
    appServiceAPIEnvVarENV: appServiceAPIEnvVarENV
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    dockerRegistryName: containerRegistryName
    appServiceAPISecretKey: appServiceAPISecretKey
    appInsightsConnectionString: appInsightsConnectionString
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey


  }
  dependsOn: [
    postgresql
    keyVault

    logAnalytics
  ]
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName


module staticWebApp 'modules/static-web-frontend.bicep' = {
  name: 'staticWebApp'
  params: {
    location: location
    name: staticWebAppName
    environmentType: environmentType
  }
}


resource sloWorkbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid('devious-workbook')
  location: location
  kind: 'shared'
  properties: {
    displayName: 'Devious Bank Workbook'
    serializedData: loadTextContent('workbooks/workbook.json')
    version: '1.0'
    sourceId: appInsights.outputs.appInsightsId
    category: 'workbook'
  }
  dependsOn: [
    appInsights
    logAnalytics
  ]
}

module logicApp 'modules/logic-app.bicep' = {
  name: 'logicApp'
  params: {
    location: location
    name: logicAppName
    slackWebhookUrl: slackWebhookUrl
  }
}

module alerts 'modules/alerts.bicep' = {
  name: 'alerts'
  params: {
    appInsightsId: appInsights.outputs.appInsightsId
    appServicePlanId: appService.outputs.appServicePlanId
    webAppId: appService.outputs.webAppId
    logicAppId: logicApp.outputs.logicAppId
  }
  dependsOn: [
    logicApp
    appInsights
    appService
  ]
}
