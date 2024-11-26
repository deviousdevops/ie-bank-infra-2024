param location string = resourceGroup().location
param storageAccountName string
param environmentType string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: (environmentType == 'prod') ? 'Standard_LRS' : 'Standard_RAGRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

output storageAccountConnectionString string = storageAccount.properties.primaryEndpoints.blob
