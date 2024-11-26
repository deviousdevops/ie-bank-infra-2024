param location string = resourceGroup().location
param serverName string
param databaseName string
param adminUser string
@secure()
param adminPassword string
@allowed(['nonprod', 'prod'])
param environmentType string

var sku = (environmentType == 'prod') ? {
  name: 'GP_Gen5_4'
  tier: 'GeneralPurpose'
  capacity: 4
} : {
  name: 'GP_Gen5_2'
  tier: 'GeneralPurpose'
  capacity: 2
}

resource postgresqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  sku: sku
  properties: {
    administratorLogin: adminUser
    administratorLoginPassword: adminPassword
    version: '12'
  }
}


output postgresqlServerFqdn string = postgresqlServer.properties.fullyQualifiedDomainName
output databaseName string = databaseName
