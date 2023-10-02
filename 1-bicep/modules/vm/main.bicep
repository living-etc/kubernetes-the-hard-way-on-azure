param publicKey string
param projectNameAbbrv string
param location string
param privateIp string
param instanceName string

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: projectNameAbbrv
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'kthw', 'Subnet')
          }
          privateIPAddress: privateIp
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    disableTcpStateTracking: false
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: instanceName
  location: location

  properties: {
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
    }

    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }

    osProfile: {
      computerName: 'Node'
      adminUsername: 'ubuntu'
      adminPassword: 'ubuntu'

      linuxConfiguration: {
        disablePasswordAuthentication: true

        ssh: {
          publicKeys: [
            {
              keyData: publicKey
              path: '/home/ubuntu/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
  }
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: projectNameAbbrv
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: toLower('${projectNameAbbrv}-${uniqueString(resourceGroup().id, projectNameAbbrv)}')
    }
  }
}
