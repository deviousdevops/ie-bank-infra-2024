param location string = resourceGroup().location
param name string
@secure()
param adminPassword string
param tenantId string = subscription().tenantId

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
}
/*
resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  name: '${keyVault.name}/admin-password'
  properties: {
    value: adminPassword
  }
}
*/
resource adminPasswordSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault    // Use parent property
  name: 'adminPassword'
  properties: {
    value: adminPassword
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
