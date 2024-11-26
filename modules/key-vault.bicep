param location string = resourceGroup().location
param name string
@secure()
param adminPassword string
param registryName string
param objectId string
param workspaceResourceId string

// Reference an existing container registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: registryName
  scope: resourceGroup()
}

// Create a new Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          keys: [
            'get'
            'list'
            'create'
            'delete'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
          ]
          certificates: [
            'get'
            'list'
            'create'
            'delete'
          ]
        }
      }
    ]
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableRbacAuthorization: false
  }
}

// Store the admin password in Key Vault
resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'adminPassword'
  properties: {
    value: adminPassword
  }
  dependsOn: [
    keyVault
  ]
}

// Store the registry admin password in Key Vault
resource registryPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'registry-password'
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
  dependsOn: [
    containerRegistry
    keyVault
  ]
}

// Store the registry admin username in Key Vault
resource registryUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'registry-username'
  properties: {
    value: containerRegistry.name
  }
  dependsOn: [
    containerRegistry
    keyVault
  ]
}

// Add Diagnostic Settings to send logs to Log Analytics
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${keyVault.name}-diagnostic'
  scope: keyVault
  properties: {
    workspaceId: workspaceResourceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
  dependsOn: [
    keyVault
  ]
}

// Output only the Key Vault URI (non-sensitive information)
output keyVaultUri string = keyVault.properties.vaultUri
