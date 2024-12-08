param location string
param name string
@allowed(['dev', 'uat', 'prod'])
param environmentType string
param sku string = (environmentType == 'prod') ? 'Standard' : 'Free'
param keyVaultName string

resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: name
  location: location
  sku: {
    name: 'Free'
    tier: sku
  }
  properties: {}
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: keyVaultName
}

resource deploymentTokenSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: 'static-web-deployment-token'
  properties: {
    value: staticWebApp.listSecrets().properties.apiKey
  }
}

output staticWebAppUrl string = staticWebApp.properties.defaultHostname



