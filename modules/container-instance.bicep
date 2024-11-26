param location string
param name string
param image string
param cpuCores int = 1
param memoryInGb int = 2
param environmentType string
param registryServer string
@secure()
param registryUsername string
@secure()
param registryPassword string

resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
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
              memoryInGB: memoryInGb
            }
          }
          environmentVariables: [
            {
              name: 'ENV'
              value: environmentType
            }
          ]
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
        }
      }
    ]
    osType: 'Linux'
    imageRegistryCredentials: [
      {
        server: registryServer
        username: registryUsername
        password: registryPassword
      }
    ]
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
    restartPolicy: 'Always'
  }
}

output containerIPv4Address string = containerInstance.properties.ipAddress.ip
