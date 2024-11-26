param location string = resourceGroup().location
param name string
param addressSpace string = '10.0.0.0/16'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressSpace]
    }
    subnets: [
      {
        name: 'AppSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'DatabaseSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}
output vnetId string = virtualNetwork.id
output appSubnetId string = virtualNetwork.properties.subnets[0].id
output databaseSubnetId string = virtualNetwork.properties.subnets[1].id
