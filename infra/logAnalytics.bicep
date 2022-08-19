param resourceToken string
param location string
param tags object

var abbrs = loadJsonContent('abbreviations.json')

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
  location: location
  tags: tags
}

resource logAnalyticsDiagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'Send_To_LogAnalytics'
  scope: logAnalytics
  properties: {
    workspaceId: logAnalytics.id
    logs: [
      {
        enabled: true
        category: 'Audit'
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

output logAnalyticsId string = logAnalytics.id
