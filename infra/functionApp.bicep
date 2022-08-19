// param functionsHostingPlanName string
// param functionsAppName string
// param functionsAppStorageName string
param appInsightsInstrumentationKey string
param logAnalyticsId string
// param location string = resourceGroup().location
// param tags object = {}
param additionalSettings array = []

param resourceToken string
param location string
param tags object

var abbrs = loadJsonContent('abbreviations.json')
var finalSettings = concat(basicSettings, additionalSettings)

var basicSettings = [
  {
    name: 'AzureWebJobsStorage'
    value: storageAccount.outputs.storageAccountConnectionString
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: storageAccount.outputs.storageAccountConnectionString
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: 'InstrumentationKey=${appInsightsInstrumentationKey}'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
]

module storageAccount './storage.bicep' = {
  name: 'Function-Storage'
  params: {
    storageAccountName: '${abbrs.storageStorageAccounts}func${resourceToken}'
    location: location
    logAnalyticsId: logAnalyticsId
    tags: tags
  }
}

resource appService 'Microsoft.Web/serverfarms@2020-06-01' = {
  // name: functionsHostingPlanName
  name: '${abbrs.webServerFarms}${resourceToken}'
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  tags: tags
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  // name: functionsAppName
  name: '${abbrs.webSitesFunctions}${resourceToken}'
  location: location
  kind: 'functionapp'
  dependsOn: [
    storageAccount
  ]

  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appService.id
    siteConfig: {
      appSettings: finalSettings
    }
  }
  tags: tags
}

output storageAccountConnectionString string = storageAccount.outputs.storageAccountConnectionString
