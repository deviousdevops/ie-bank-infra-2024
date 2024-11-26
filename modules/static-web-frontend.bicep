param location string = resourceGroup().location
param name string
@allowed(['nonprod', 'prod'])
param environmentType string
param sku string = (environmentType == 'prod') ? 'Standard' : 'Free'
@secure()
param repositoryToken string // token for repository
param repositoryUrl string // URL for deployment
param appLocation string = 'src' // default app location
param apiLocation string = '' // API location
param appBuildCommand string = 'npm run build' 
param apiBuildCommand string = '' // API build command
param appArtifactLocation string = 'dist' 

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned' 
  }
  properties: {
    repositoryToken: repositoryToken
    repositoryUrl: repositoryUrl
    buildProperties: {
      apiLocation: apiLocation
      apiBuildCommand: apiBuildCommand
      appLocation: appLocation
      appBuildCommand: appBuildCommand
      appArtifactLocation: appArtifactLocation
      skipGithubActionWorkflowGeneration: false
    }
    publicNetworkAccess: 'Enabled' 
  }
  tags: {
    environment: environmentType
    project: 'Devious DevOps'
    owner: 'Alvaro Guadamillas'
  }
}

output staticWebAppUrl string = staticWebApp.properties.defaultHostname
output staticWebAppId string = staticWebApp.id


