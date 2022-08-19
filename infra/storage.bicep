// param location string = resourceGroup().location
param storageAccountName string
param logAnalyticsId string
// param tags object = {}

// param resourceToken string
param location string
param tags object

var abbrs = loadJsonContent('abbreviations.json')

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource eventHubNamespaceDiagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'Send_To_LogAnalytics'
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsId

    metrics: [
      {
        enabled: true
        category: 'Transaction'
      }
    ]
  }
}

output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
