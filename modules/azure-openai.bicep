param azureOpenAiName string
param location string
param azureOpenModel string

resource azureOpenAi 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: azureOpenAiName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: azureOpenAiName
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: []
      ipRules: []
    }
    publicNetworkAccess: 'Disabled'
  }
}

// resource azureOpenAiModel 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
//   parent: azureOpenAi
//   name: 'GPT-3_5-Turbo-16k'
//   sku: {
//     name: 'Standard'
//     capacity: 120
//   }
//   properties: {
//     model: {
//       format: 'OpenAI'
//       name: azureOpenModel
//     }
//     versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
//     raiPolicyName: 'Microsoft.Default'
//   }
// }

output fqdn string = split(azureOpenAi.properties.endpoint, '/')[2]
