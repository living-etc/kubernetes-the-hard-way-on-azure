param networkName string
param vnetAddressPrefixes string
param subnetAddressPrefixes string
param podCidrPrefixes string
param location string

output subnetId string = virtualNetwork.properties.subnets[0].id
output id string = virtualNetwork.id

var securityRules = [
  {
    name: 'allow-all-tcp-from-internal-vm-network'
    protocol: 'tcp'
    port: '*'
    priority: 1000
    sourceAddressPrefix: subnetAddressPrefixes
  }
  {
    name: 'allow-all-udp-from-internal-vm-network'
    protocol: 'udp'
    port: '*'
    priority: 1100
    sourceAddressPrefix: subnetAddressPrefixes
  }
  {
    name: 'allow-all-icmp-from-internal-vm-network'
    protocol: 'icmp'
    port: '*'
    priority: 1200
    sourceAddressPrefix: subnetAddressPrefixes
  }
  {
    name: 'allow-all-tcp-from-internal-pod-networks'
    protocol: 'tcp'
    port: '*'
    priority: 1300
    sourceAddressPrefix: podCidrPrefixes
  }
  {
    name: 'allow-all-udp-from-internal-pod-networks'
    protocol: 'udp'
    port: '*'
    priority: 1400
    sourceAddressPrefix: podCidrPrefixes
  }
  {
    name: 'allow-all-icmp-from-internal-pod-networks'
    protocol: 'icmp'
    port: '*'
    priority: 1500
    sourceAddressPrefix: podCidrPrefixes
  }
  {
    name: 'allow-all-ssh-from-external-sources'
    protocol: 'tcp'
    port: 22
    priority: 1600
    sourceAddressPrefix: '0.0.0.0/0'
  }
  {
    name: 'allow-all-https-from-external-sources'
    protocol: 'tcp'
    port: 6443
    priority: 1700
    sourceAddressPrefix: '0.0.0.0/0'
  }
  {
    name: 'allow-all-icmp-from-external-sources'
    protocol: 'icmp'
    port: '*'
    priority: 1800
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
