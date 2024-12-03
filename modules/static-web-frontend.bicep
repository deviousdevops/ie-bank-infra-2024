@description('Module to deploy a Static Web App with configurable SKU based on environment type')
param location string = resourceGroup().location
param name string
@allowed(['nonprod', 'prod'])
param environmentType string
param sku string = (environmentType == 'prod') ? 'Standard' : 'Free'

// Define the Static Web App resource
resource staticWebApp 'Microsoft.Web/staticSites@2022-03-01' = {
  name: name
  location: location
  sku: {
    name: 'Free'  // This should always be 'Free' as per your original config
    tier: sku
  }
  properties: {
    repositoryToken: '<REPOSITORY-TOKEN>'  // Replace with actual token
  }
}

// Output the Static Web App URL
output staticWebAppUrl string = staticWebApp.properties.defaultHostname

