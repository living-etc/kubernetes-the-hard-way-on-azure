param networkName string
param vnetAddressPrefixes string
param subnetAddressPrefixes string
param location string

output subnetId string = virtualNetwork.properties.subnets[0].id

var securityRules = [
  {
    name: 'allow-all-tcp-from-internal-sources'
    protocol: 'tcp'
    port: '*'
    priority: 1000
    sourceAddressPrefix: subnetAddressPrefixes
  }
  {
    name: 'allow-all-udp-from-internal-sources'
    protocol: 'udp'
    port: '*'
    priority: 1100
    sourceAddressPrefix: subnetAddressPrefixes
  }
  {
    name: 'allow-all-icmp-from-internal-sources'
    protocol: 'icmp'
    port: '*'
    priority: 1200
    sourceAddressPrefix: subnetAddressPrefixes
  }
  {
    name: 'allow-all-ssh-from-external-sources'
    protocol: 'tcp'
    port: 22
    priority: 1300
    sourceAddressPrefix: '0.0.0.0/0'
  }
  {
    name: 'allow-all-https-from-external-sources'
    protocol: 'tcp'
    port: 6443
    priority: 1400
    sourceAddressPrefix: '0.0.0.0/0'
  }
  {
    name: 'allow-all-icmp-from-external-sources'
    protocol: 'tcp'
    port: '*'
    priority: 1500
    sourceAddressPrefix: '0.0.0.0/0'
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: networkName
  location: location
  properties: {
    securityRules: [for (rule, index) in securityRules: {
      name: rule.name
      properties: {
        priority: rule.priority
        access: 'Allow'
        direction: 'Inbound'
        destinationPortRange: '*'
        protocol: rule.protocol
        sourcePortRange: '*'
        sourceAddressPrefix: rule.sourceAddressPrefix
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
            id: nsg.id
          }
        }
      }
    ]
  }
}
