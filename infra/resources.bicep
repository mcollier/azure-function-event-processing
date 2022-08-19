param location string
param principalId string = ''
param resourceToken string
param tags object
param sensorType string = 'yellow'

var abbrs = loadJsonContent('abbreviations.json')

// var logAnalyticsName = take('log-${resourcenamePrefix}-${environmedntNamePrefix}', 63)
// var appInsightsName = take('appi-${resourcenamePrefix}-${environmedntNamePrefix}', 255)
var functionAppName = '${abbrs.webSitesFunctions}${resourceToken}'

// var eventHubNamespaceName = take('evhns-${resourcenamePrefix}-${environmedntNamePrefix}', 50)
// var inputEventHubName = 'evh-${resourcenamePrefix}-in-${environmedntNamePrefix}'
// var outputEventHubName = 'evh-${resourcenamePrefix}-out-${environmedntNamePrefix}'
var inputEventHubName = '${abbrs.eventHubNamespacesEventHubs}${resourceToken}-in'
var outputEventHubName = '${abbrs.eventHubNamespacesEventHubs}${resourceToken}-out'

// var outputStorageAccountName = take(toLower('st${resourcenamePrefix}${environmedntNamePrefix}${uniqueString(resourceGroup().name)}'), 23)

// var functionsHostingPlanName = take('plan-${resourcenamePrefix}-${environmedntNamePrefix}', 40)
// var functionsAppName = take('func-${resourcenamePrefix}-${environmedntNamePrefix}', 60)
// var functionsAppStorageName = take('stfunc${resourcenamePrefix}${environmedntNamePrefix}', 23)

module logAnalytics './logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    location: location
    resourceToken: resourceToken
    tags: union(tags, {
        'azd-service-name': 'azure-function-event-processing'
      })
  }
}

module applicationInsights './appInsights.bicep' = {
  name: 'appInsights'
  params: {
    location: location
    resourceToken: resourceToken
    workspaceId: logAnalytics.outputs.logAnalyticsId
    tags: union(tags, {
        'azd-service-name': 'azure-function-event-processing'
      })
  }
}

module eventHubs './eventHub.bicep' = {
  name: 'eventHubs'
  params: {
    location: location
    resourceToken: resourceToken
    inputHubName: inputEventHubName
    outputHubName: outputEventHubName
    functionName: functionAppName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: union(tags, {
        'azd-service-name': 'azure-function-event-processing'
      })
  }
}

module storageAccount './storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    storageAccountName: '${abbrs.storageStorageAccounts}${resourceToken}'
    // storageAccountName: outputStorageAccountName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: union(tags, {
        'azd-service-name': 'azure-function-event-processing'
      })
  }
}

module functionApp './functionApp.bicep' = {
  name: 'functionApp'
  params: {
    resourceToken: resourceToken
    // functionsAppName: functionAppName
    // functionsHostingPlanName: functionsHostingPlanName
    // functionsAppStorageName: functionsAppStorageName
    appInsightsInstrumentationKey: applicationInsights.outputs.appInsightsInstrumentationKey
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    location: location
    tags: union(tags, {
        'azd-service-name': 'azure-function-event-processing'
      })

    //Send in additional settings that connect the function to other components
    additionalSettings: [
      {
        name: 'Input_EH_Name'
        value: eventHubs.outputs.inputHubName
      }
      {
        name: 'InputEventHubConnectionString'
        value: eventHubs.outputs.eventHubConnectionStringListen
      }
      {
        name: 'Input_EH_ConsumerGroup'
        value: eventHubs.outputs.inputConsumerGroup
      }
      {
        name: 'Output_EH_Name'
        value: eventHubs.outputs.outputHubName
      }
      {
        name: 'OutputEventHubConnectionString'
        value: eventHubs.outputs.eventHubConnectionStringSend
      }
      {
        name: 'SENSOR_TYPE'
        value: sensorType
      }
    ]
  }
}
