param location string = resourceGroup().location
param name string
param sku string
param workspaceResourceId string

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
resource containerRegistryDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${containerRegistry.name}-diagnostic'
  scope: containerRegistry
  properties: {
    workspaceId: workspaceResourceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'ContainerRegistryRepositoryEvents'
        enabled: true
      }
      {
        category: 'ContainerRegistryLoginEvents'
        enabled: true
      }
    ]
  }
}

output registryLoginServer string = containerRegistry.properties.loginServer

