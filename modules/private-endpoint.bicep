param vnetName string
param privateEndpointName string
param privateEndpointNicName string
param location string
param azureOpenAiName string

resource parentVnet 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: vnetName
}

resource parentAzureOpenAi 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: azureOpenAiName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  dependsOn: [
    parentAzureOpenAi
  ]
  properties: {
    subnet: {
      id: parentVnet.properties.subnets[0].id
    }
    customNetworkInterfaceName: privateEndpointNicName
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: resourceId('Microsoft.CognitiveServices/accounts', azureOpenAiName)
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

output privateIpAddress string = privateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]
