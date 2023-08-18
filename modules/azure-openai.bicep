param azureOpenAiName string
param location string

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

resource azureOpenAiModel 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: azureOpenAi
  name: 'GPT-3_5-Turbo'
  sku: {
    name: 'Standard'
    capacity: 120
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-ada-002'
      version: '2'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    raiPolicyName: 'Microsoft.Default'
  }
}
