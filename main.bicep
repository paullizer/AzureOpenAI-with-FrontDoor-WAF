@description('The location into which regionally scoped resources should be deployed. Note that Front Door is a global resource.')
param location string = resourceGroup().location

@description('The IP address prefix (CIDR range) to use when deploying the virtual network.')
param vnetIPPrefix string = '10.0.0.0/16'

@description('The IP address prefix (CIDR range) to use when deploying the API Management subnet within the virtual network.')
param priveEndpointSubnetIPPrefix string = '10.0.0.0/24'



var vnetName = 'vNet-${uniqueString(resourceGroup().id)}'
var azureOpenAiName = 'aoai-${uniqueString(resourceGroup().id)}'
var logAnalyticsName = 'law-${uniqueString(resourceGroup().id)}'
var applicationInsightsName = 'appIn-${uniqueString(resourceGroup().id)}'
var privateEndpointName = '${uniqueString(resourceGroup().id)}-pip'
var privateEndpointNicName = '${uniqueString(resourceGroup().id)}-pip-nic'
var frontDoorName = 'fd-${uniqueString(resourceGroup().id)}'

var privateDnsZoneName = 'privatelink.azure-api.net'


var privateEndpointSubnetName = 'privateEndpointSubnet'

module logAnalyticsWorkspace 'modules/log-analytics-workspace.bicep' = {
  name: 'log-analytics-workspace'
  params: {
    location: location
    logAnalyticsName: logAnalyticsName
    applicationInsightsName : applicationInsightsName
  }
}

module network 'modules/network.bicep' = {
  name: 'network'
  params: {
    vnetName: vnetName
    location: location
    vnetIPPrefix: vnetIPPrefix
    priveEndpointSubnetIPPrefix: priveEndpointSubnetIPPrefix
    privateEndpointSubnetName: privateEndpointSubnetName
  }
  dependsOn: [
    logAnalyticsWorkspace
  ]
}

module azureOpenAi 'modules/azure-openai.bicep' = {
  name: 'azure-openai'
  params: {
    azureOpenAiName: azureOpenAiName
    location: location
  }
  dependsOn: [
    network
  ]
}

module privateEndpoint 'modules/private-endpoint.bicep' = {
  name: 'private-endpoint'
  params: {
    privateEndpointNicName: privateEndpointNicName
    privateEndpointName: privateEndpointName
    vnetName: vnetName
    location: location
    azureOpenAiName: azureOpenAiName
  }
  dependsOn: [
    network
    azureOpenAi
  ]
}

module privateDnsZone 'modules/private-dns-zone.bicep' = {
  name: 'private-dns-zone'
  params: {
    privateDnsZoneName: privateDnsZoneName
    vnetResourceId: network.outputs.resourceId
    privateEndpointName: privateEndpointName
    privateEndpointIpAddress: privateEndpoint.outputs.privateIpAddress

  }
  dependsOn: [
    network
    azureOpenAi
    privateEndpoint
  ]
}

module frontDoor 'modules/front-door.bicep' = {
  name: 'front-door'
  params: {
    frontDoorName: frontDoorName
    privateEndpointIpAddress: privateEndpoint.outputs.privateIpAddress
  }
  dependsOn: [
    network
    azureOpenAi
    privateDnsZone
    privateEndpoint
  ]
}
