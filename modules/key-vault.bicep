param location string = resourceGroup().location
param name string
@secure()
param adminPassword string
param registryName string
param objectId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: registryName
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
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
          keys: [
            'get'
            'list'
            'create'
            'delete'
          ]
        }
      }
    ]
    enableRbacAuthorization: false
  }
}

resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'adminPassword'
  properties: {
    value: adminPassword
  }
}

resource registryPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'registry-password'
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

resource registryUsernameSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'registry-username'
  properties: {
    value: containerRegistry.name
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
