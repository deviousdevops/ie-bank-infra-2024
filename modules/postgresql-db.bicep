param location string
param serverName string
param databaseName string
param postgreSQLAdminServicePrincipalObjectId string
param postgreSQLAdminServicePrincipalName string

var sku = {
  name: 'Standard_B1ms'
  tier: 'Burstable'
}

resource postgresqlServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: toLower(replace(serverName, '_', '-'))
  location: location
  sku: sku
  properties: {
    version: '15'
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
      standbyAvailabilityZone: ''
    }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: subscription().tenantId
    }
  }
}

resource firewallRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-12-01' = {
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  parent: postgresqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource postgreSQLAdministrators 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2022-12-01' = {
  parent: postgresqlServer
  name: postgreSQLAdminServicePrincipalObjectId
  properties: {
    principalName: postgreSQLAdminServicePrincipalName
    principalType: 'ServicePrincipal'
    tenantId: subscription().tenantId
  }
  dependsOn: [
    firewallRule
  ]
}

output postgresqlServerFqdn string = postgresqlServer.properties.fullyQualifiedDomainName
output databaseName string = databaseName
output serverId string = postgresqlServer.id
output serverName string = postgresqlServer.name
