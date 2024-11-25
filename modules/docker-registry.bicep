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
    adminUserEnabled: false
  }
}

output containerRegistryLoginServer string = containerRegistry.properties.loginServer
output containerRegistryAdminUsername string = containerRegistry.listCredentials().username
output containerRegistryPassword0 string = containerRegistry.listCredentials().passwords[0].value
output containerRegistryPassword1 string =  containerRegistry.listCredentials().passwords[1].value
