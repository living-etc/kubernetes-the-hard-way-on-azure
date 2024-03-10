param publicKey string
param location string
param privateIp string
param instanceName string
param tags object
param subnet string
param loadBalancerBackendPool string = ''
param loadBalancer string = ''

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: instanceName
  location: location

  properties: {
    disableTcpStateTracking: false
    enableIPForwarding: true
    ipConfigurations: [
      {
        name: 'primary'
        properties: {
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet
          }
          privateIPAddress: privateIp
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: publicIP.id
          }
          loadBalancerBackendAddressPools: !empty(loadBalancer) && !empty(loadBalancerBackendPool) ? [
          {
              id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancer, loadBalancerBackendPool) 
            }
          ] : []
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: instanceName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${instanceName}-kthw-cw'
    }
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: instanceName
  location: location
  tags: tags

  properties: {
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 32
      }
    }

    hardwareProfile: {
      vmSize: 'Standard_B2s'
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
