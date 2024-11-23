param location string = resourceGroup().location
param name string
@allowed(['Basic', 'Standard', 'Premium'])
param sku string = (environmentType == 'prod') ? 'Standard' : 'Basic'
@allowed(['nonprod', 'prod'])
param environmentType string

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

output containerRegistryLoginServer string = containerRegistry.properties.loginServer
output containerRegistryUserName string = containerRegistry.listCredentials().username

