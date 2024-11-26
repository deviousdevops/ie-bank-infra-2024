param location string = resourceGroup().location
param name string
param vnetName string
param subnetName string

resource appGateway 'Microsoft.Network/applicationGateways@2021-05-01' = {
  name: name
  location: location
  properties: {
    gatewayIPConfigurations: [
      {
        name: 'gatewayIPConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
          }
        }
      }
    ]
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      capacity: 2
    }
    frontendIPConfigurations: [
      {
        name: 'frontendIP'
        properties: {
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${name}-publicIP')
          }
        }
      }
    ]
  }
}
