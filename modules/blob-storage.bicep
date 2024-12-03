@description('Module to deploy a Storage Account with configurable replication type')
param location string = resourceGroup().location
param storageAccountName string
param environmentType string

// Define the Storage Account resource
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

// Output the Blob endpoint connection string
output storageAccountConnectionString string = storageAccount.properties.primaryEndpoints.blob
