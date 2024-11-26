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

resource postgresqlServer 'Microsoft.DBforPostgreSQL/servers@2021-06-01' = {
  name: serverName
  location: location
  sku: sku
  properties: {
    administratorLogin: adminUser
    administratorLoginPassword: adminPassword
    version: '12'
    sslEnforcement: 'Enabled'
  }
}

resource postgresqlDatabase 'Microsoft.DBforPostgreSQL/servers/databases@2021-06-01' = {
  name: '${serverName}/${databaseName}'
  properties: {}
}

output postgresqlConnectionString string = 'Server=${postgresqlServer.properties.fullyQualifiedDomainName};Database=${databaseName};User Id=${adminUser};Password=${adminPassword};'

