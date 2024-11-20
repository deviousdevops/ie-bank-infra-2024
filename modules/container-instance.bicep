param location string
param name string
param image string
param cpuCores int = 1
param memoryInGb float = 1.5

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-07-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: name
        properties: {
          image: image
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGb: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
  }
}
