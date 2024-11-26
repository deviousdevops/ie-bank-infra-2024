param location string = resourceGroup().location
param name string
@allowed([
  'nonprod'
  'prod'
])
param environmentType string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: true
  }
}

output registryLoginServer string = containerRegistry.properties.loginServer
output adminUsername string = containerRegistry.properties.loginServer
output adminPassword string = containerRegistry.listCredentials().passwords[0].value

