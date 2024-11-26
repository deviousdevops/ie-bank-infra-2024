param location string = resourceGroup().location
param appServicePlanName string
param appServiceAppName string
param appServiceAPIAppName string
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

// Parameters for Docker support
@allowed([
  'python'
  'node'
  'docker'
])
param deploymentType string = 'python' // Default to 'python'
param dockerRegistryName string = ''
@secure()
param dockerRegistryServerUserName string = ''
@secure()
param dockerRegistryServerPassword string = ''
param dockerRegistryImageName string = ''
param dockerRegistryImageVersion string = 'latest'
param appCommandLine string = ''

var appServicePlanSkuName = (environmentType == 'prod') ? 'P1v2' : 'B1'

// Define Docker-specific app settings
var dockerAppSettings = [
  { name: 'DOCKER_REGISTRY_SERVER_URL', value: 'https://${dockerRegistryName}.azurecr.io' }
  { name: 'DOCKER_REGISTRY_SERVER_USERNAME', value: dockerRegistryServerUserName }
  { name: 'DOCKER_REGISTRY_SERVER_PASSWORD', value: dockerRegistryServerPassword }
]

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: appServicePlanSkuName
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// Python or Node.js App Service
resource appServiceAPIApp 'Microsoft.Web/sites@2022-03-01' = if (deploymentType != 'docker') {
  name: appServiceAPIAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: (deploymentType == 'python') ? 'PYTHON|3.11' : 'NODE|18-lts'
      alwaysOn: (deploymentType == 'python')
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

// Docker App Service
resource appServiceDockerApp 'Microsoft.Web/sites@2022-03-01' = if (deploymentType == 'docker') {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${dockerRegistryName}.azurecr.io/${dockerRegistryImageName}:${dockerRegistryImageVersion}'
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      appCommandLine: appCommandLine
      appSettings: union(dockerAppSettings, [])
    }
  }
}

// Output the hostname based on the deployment type
output appServiceApiHostName string = (deploymentType == 'docker') ? appServiceDockerApp.properties.defaultHostName : appServiceAPIApp.properties.defaultHostName


