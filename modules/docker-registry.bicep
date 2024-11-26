param location string = resourceGroup().location
param name string
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

resource acrDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'ContainerRegistryDiagnostic'
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
        category: 'ContainerRegistryLoginEvents'  
        enabled: true
      }
      {
        category: 'ContainerRegistryRepositoryEvents'  
        enabled: true
      }
    ]
  }
}

output registryLoginServer string = containerRegistry.properties.loginServer
