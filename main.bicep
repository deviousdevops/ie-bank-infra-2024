@sys.description('The environment type (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environmentType string = 'nonprod'
@sys.description('The user alias to add to the deployment name')
param userAlias string = 'aguadamillas'
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
param appServiceAPIDBHostFLASK_APP string
@sys.description('The value for the environment variable FLASK_DEBUG')
param appServiceAPIDBHostFLASK_DEBUG string

// Add new parameters needed for other resources
param vnetName string
param keyVaultName string
param storageAccountName string
param tenantId string = subscription().tenantId
param containerRegistryName string
param applicationInsightsName string
param logAnalyticsWorkspaceName string
param staticWebAppName string

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
  }
  dependsOn: [
    postgresql
    keyVault
    storage
  ]
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName

// Add other modules
/* 
module vnet 'modules/vnet.bicep' = {
  name: 'vnet'
  params: {
    location: location
    name: vnetName
  }
}
*/

module keyVault 'modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    name: keyVaultName
    adminPassword: appServiceAPIEnvVarDBPASS
    tenantId: tenantId    // Add this line

  }
}

module storage 'modules/blob-storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
    environmentType: environmentType
  }
}

module containerRegistry 'modules/docker-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    location: location
    name: containerRegistryName
    sku: 'Standard'
    environmentType: environmentType
  }
}

module appInsights 'modules/app-insights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    name: applicationInsightsName
    environmentType: environmentType
  }
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    name: logAnalyticsWorkspaceName
    environmentType: environmentType
  }
}

module staticWebApp 'modules/static-web-frontend.bicep' = {
  name: 'staticWebApp'
  params: {
    location: location
    name: staticWebAppName
    environmentType: environmentType
  }
}
// Add private endpoint after PostgreSQL and VNet are deployed
/* 
module privateEndpoint 'modules/private-endpoint.bicep' = {
  name: 'privateEndpoint'
  params: {
    location: location
    name: '${postgreSQLServerName}-pe'
    postgresServerId: postgresSQLServer.id
    vnetName: vnetName
    subnetName: 'DatabaseSubnet'
  }
  dependsOn: [
    vnet
  ]
}
*/

module postgresql 'modules/postgresql-db.bicep' = {
  name: 'postgresql-deployment'
  params: {
    location: location
    serverName: postgreSQLServerName
    databaseName: postgreSQLDatabaseName
    adminUser: appServiceAPIDBHostDBUSER
    adminPassword: appServiceAPIEnvVarDBPASS
    environmentType: environmentType
  }
}

output storageAccountConnectionString string = storage.outputs.storageAccountConnectionString

// Add this module call
module backendContainer './modules/container-instance.bicep' = {
  name: 'backend-container'
  params: {
    location: location
    name: '${appServiceAPIAppName}-container'
    image: '${containerRegistry.outputs.registryLoginServer}/ie-bank-api:latest'
    cpuCores: 1
    memoryInGb: 2
    environmentType: environmentType
    registryServer: containerRegistry.outputs.registryLoginServer
    registryUsername: containerRegistry.outputs.adminUsername
    registryPassword: containerRegistry.outputs.adminPassword
  }
  dependsOn: [
    containerRegistry
  ]
}

