param location string
param name string
@secure()
param slackWebhookUrl string

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              properties: {
                alertMessage: {
                  type: 'string'
                }
                alertName: {
                  type: 'string'
                }
                severity: {
                  type: 'string'
                }
              }
              type: 'object'
            }
          }
        }
      }
      actions: {
        Post_message_to_Slack: {
          type: 'Http'
          inputs: {
            method: 'POST'
            uri: slackWebhookUrl
            body: {
              text: '🚨 *Alert:* @{triggerBody()?[\'alertName\']}\n*Severity:* @{triggerBody()?[\'severity\']}\n*Message:* @{triggerBody()?[\'alertMessage\']}'
            }
          }
        }
      }
    }
  }
}

output logicAppId string = logicApp.id
output logicAppEndpoint string = listCallbackUrl('${logicApp.id}/triggers/manual', logicApp.apiVersion).value 
