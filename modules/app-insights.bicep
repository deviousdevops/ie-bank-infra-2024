param location string
param name string
param applicationType string = 'web'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: applicationType
  properties: {
    Application_Type: applicationType
  }
}

