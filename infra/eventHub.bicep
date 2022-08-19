param resourceToken string
param location string
param tags object

// param eventHubNamespaceName string
param inputHubName string
param outputHubName string
param logAnalyticsId string
param functionName string
// param location string = resourceGroup().location
param partitionCount int = 2

// param tags object = {}

var abbrs = loadJsonContent('abbreviations.json')

//Make sure the namespce is there
resource eventHubNs 'Microsoft.EventHub/namespaces@2018-01-01-preview' = {
  name: '${abbrs.eventHubNamespaces}${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource inputHub 'eventhubs' = {
    name: inputHubName
    properties: {
      partitionCount: partitionCount
    }

    resource inputConsumerGroup 'consumergroups' = {
      name: '${functionName}-inputGroup'
    }
  }

  resource outputHub 'eventhubs' = {
    name: outputHubName
    properties: {
      partitionCount: partitionCount
    }
  }

  resource sendPolicy 'authorizationRules' = {
    name: '${functionName}-Send'
    properties: {
      rights: [
        'Send'
      ]
    }
  }

  resource listenPolicy 'authorizationRules' = {
    name: '${functionName}-Listen'
    properties: {
      rights: [
        'Listen'
      ]
    }
  }
}

// Add the event hub
// resource inputHub 'Microsoft.EventHub/namespaces/eventhubs@2017-04-01' = {
//   name: '${eventHubNs.name}/${abbrs.eventHubNamespacesEventHubs}${inputHubName}'
//   properties: {
//     partitionCount: partitionCount
//   }
// }

// resource outputtHub 'Microsoft.EventHub/namespaces/eventhubs@2017-04-01' = {
//   name: '${eventHubNs.name}/${abbrs.eventHubNamespacesEventHubs}${outputHubName}'
//   properties: {
//     partitionCount: partitionCount
//   }
// }

// resource inputConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2017-04-01' = {
//   name: '${inputHub.name}/${functionName}-inputGroup'
// }

// resource sendPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2017-04-01' = {
//   name: '${eventHubNs.name}/${functionName}-Send'
//   properties: {
//     rights: [
//       'Send'
//     ]
//   }
// }

// resource listenPolicy 'Microsoft.EventHub/namespaces/authorizationRules@2017-04-01' = {
//   name: '${eventHubNs.name}/${functionName}-Listen'
//   properties: {
//     rights: [
//       'Listen'
//     ]
//   }
// }

resource eventHubNamespaceDiagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'Send_To_LogAnalytics'
  scope: eventHubNs
  properties: {
    workspaceId: logAnalyticsId
    logs: [
      {
        category: 'ArchiveLogs'
        enabled: true
      }
      {
        category: 'OperationalLogs'
        enabled: true
      }
      {
        category: 'AutoScaleLogs'
        enabled: true
      }
      {
        category: 'KafkaCoordinatorLogs'
        enabled: true
      }
      {
        category: 'KafkaUserErrorLogs'
        enabled: true
      }
      {
        category: 'EventHubVNetConnectionEvent'
        enabled: true
      }
      {
        category: 'CustomerManagedKeyUserLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
}

output eventHubNamespaceName string = eventHubNs.name

// output inputHubName string = last(split(inputHub.name, '/'))
output inputHubName string = last(split(eventHubNs::inputHub.name, '/'))
output outputHubName string = last(split(eventHubNs::outputHub.name, '/'))

// output inputConsumerGroup string = last(split(inputConsumerGroup.name, '/'))
output inputConsumerGroup string = last(split(eventHubNs::inputHub::inputConsumerGroup.name, '/'))

// output eventHubConnectionStringSend string = listKeys(sendPolicy.id, sendPolicy.apiVersion).primaryConnectionString
// output eventHubConnectionStringListen string = listKeys(listenPolicy.id, listenPolicy.apiVersion).primaryConnectionString

output eventHubConnectionStringSend string = listKeys(eventHubNs::sendPolicy.id, eventHubNs::sendPolicy.apiVersion).primaryConnectionString
output eventHubConnectionStringListen string = listKeys(eventHubNs::listenPolicy.id, eventHubNs::listenPolicy.apiVersion).primaryConnectionString
