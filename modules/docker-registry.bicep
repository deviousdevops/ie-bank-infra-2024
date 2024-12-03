@description('Module to deploy a Container Registry and configure diagnostics')
param location string = resourceGroup().location
param name string
param sku string
param workspaceResourceId string

// Define the Container Registry resource
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

// Define the diagnostic settings for the Container Registry
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

resource acrPushRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, githubPrincipalId, 'acrpush')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8311e382-0749-4cb8-b61a-304f252e45ec')
    principalId: githubPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, backendAppServicePrincipalId, 'acrpull')
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: backendAppServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Output the login server URL for the Container Registry
output registryLoginServer string = containerRegistry.properties.loginServer
output registryName string = containerRegistry.name
