param networkName string
param vnetAddressPrefixes string
param subnetAddressPrefixes string
param location string

output subnetId string = virtualNetwork.properties.subnets[0].id

var internalRules = [
  { protocol: 'tcp', priority: 1000 }
  { protocol: 'udp', priority: 1100 }
  { protocol: 'icmp', priority: 1200 }
]

var externalRules = [
  { protocol: 'ssh', port: 22, priority: 1000 }
  { protocol: 'https', port: 6443, priority: 1100 }
  { protocol: 'icmp', port: '*', priority: 1200 }
]

resource internal 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${networkName}-internal'
  location: location
  properties: {
    securityRules: [for (rule, index) in internalRules: {
      name: 'allow-all-${rule.protocol}'
      properties: {
        priority: rule.priority
        access: 'Allow'
        direction: 'Inbound'
        destinationPortRange: '*'
        protocol: rule.protocol
        sourcePortRange: '*'
        sourceAddressPrefix: subnetAddressPrefixes
        destinationAddressPrefix: '*'
      }
    }]
  }
}

resource external 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${networkName}-external'
  location: location
  properties: {
    securityRules: [for (rule, index) in externalRules: {
      name: 'allow-${rule.protocol}'
      properties: {
        priority: rule.priority
        access: 'Allow'
        direction: 'Inbound'
        destinationPortRange: rule.port
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: '0.0.0.0/0'
        destinationAddressPrefix: '*'
      }
    }]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: networkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefixes
      ]
    }
    subnets: [
      {
        name: 'Subnet'
        properties: {
          addressPrefix: subnetAddressPrefixes
          networkSecurityGroup: {
            id: internal.id
          }
        }
      }
    ]
  }
}
