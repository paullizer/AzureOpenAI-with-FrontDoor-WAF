param location string
param vnetIPPrefix string
param priveEndpointSubnetIPPrefix string
param vnetName string
param privateEndpointSubnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIPPrefix
      ]
    }
    subnets: [
      {
        name: privateEndpointSubnetName
        properties: {
          addressPrefix: priveEndpointSubnetIPPrefix
        }
      }
    ]
  }
}

output resourceId string = resourceId('Microsoft.Network/VirtualNetworks', vnetName)
