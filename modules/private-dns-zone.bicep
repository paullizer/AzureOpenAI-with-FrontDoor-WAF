param privateDnsZoneName string
param vnetResourceId string
param privateEndpointName string
param privateEndpointIpAddress string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
}

resource aRecordRoot 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: privateEndpointName
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: privateEndpointIpAddress
      }
    ]
  }
}

resource soa 'Microsoft.Network/privateDnsZones/SOA@2020-06-01' = {
  parent: privateDnsZone
  name: '@'
  properties: {
    ttl: 3600
    soaRecord:{
      host: 'azureprivatedns.net'
      email: 'azureprivatedns-host.microsoft.com'
      serialNumber: 1
      refreshTime: 3600
      retryTime: 300
      expireTime: 2419200
      minimumTtl: 10
    }
  }
}

resource virtualNetworkLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: privateEndpointName
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id:  resourceId('Microsoft.Network/VirtualNetworks', vnetResourceId)
    }
  }
}
