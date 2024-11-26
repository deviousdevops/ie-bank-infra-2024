param location string = resourceGroup().location
param name string
param postgresServerId string
param vnetName string
param subnetName string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: name
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: 'postgresLink'
        properties: {
          privateLinkServiceId: postgresServerId
          groupIds: ['postgresqlServer']
        }
      }
    ]
  }
}

output privateEndpointIp string = privateEndpoint.properties.ipConfigurations[0].properties.privateIPAddress
