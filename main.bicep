@sys.description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
@sys.description('The user alias to add to the deployment name')
param userAlias string = 'deviousinc'
@sys.description('The PostgreSQL Server name')
@minLength(3)
@maxLength(24)
param postgreSQLServerName string = 'ie-bank-db-server-dev'
@sys.description('The PostgreSQL Database name')
@minLength(3)
@maxLength(24)
param postgreSQLDatabaseName string = 'ie-bank-db'
@sys.description('The App Service Plan name')
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'ie-bank-app-sp-dev'
@sys.description('The Web App name (frontend)')
@minLength(3)
@maxLength(24)
param appServiceAppName string = 'ie-bank-dev'
@sys.description('The API App name (backend)')
@minLength(3)
@maxLength(24)
param appServiceAPIAppName string = 'ie-bank-api-dev'
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
param appServiceAPIDBHostFLASK_APP string = 'iebank_api'
@sys.description('The value for the environment variable FLASK_DEBUG')
param appServiceAPIDBHostFLASK_DEBUG string

// Add new parameters needed for other resources
param keyVaultName string
param containerRegistryName string
param applicationInsightsName string
param logAnalyticsWorkspaceName string
param staticWebAppName string

// Add these new parameters
param postgreSQLAdminServicePrincipalObjectId string
param postgreSQLAdminServicePrincipalName string


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
    githubPrincipalId: '25d8d697-c4a2-479f-96e0-15593a830ae5'
    backendAppServicePrincipalId: '25d8d697-c4a2-479f-96e0-15593a830ae5'
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
    githubActionsPrincipalId: '25d8d697-c4a2-479f-96e0-15593a830ae5'
    workspaceResourceId: logAnalytics.outputs.logAnalyticsWorkspaceId // Added line
  }
  dependsOn: [
    containerRegistry
    logAnalytics // Ensure dependency
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
    administratorLogin: 'iebankdbadmin'
    administratorLoginPassword: 'IE.Bank.DB.Admin.Pa$$'
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
  name: guid('Devious-SLO-Monitoring')
  location: location
  kind: 'shared'
  properties: {
    displayName: 'IE Bank SLO Dashboard'
    serializedData: '{"version":"Notebook/1.0","items":[],"isLocked":false}'  // Basic empty workbook
    version: '1.0'
    sourceId: appInsights.outputs.appInsightsId  // Changed from appInsights.id to appInsights.outputs.appInsightsId
    category: 'workbook'
  }
}
