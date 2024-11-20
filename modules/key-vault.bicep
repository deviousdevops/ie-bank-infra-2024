param location string
param name string
param tenantId string

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: name
  location: location
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
  }
}

