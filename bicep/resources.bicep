targetScope = 'resourceGroup'

param location string = resourceGroup().location
param sshPublicKey string

var projectNameAbbrv = 'kthw'
var lbName = 'k8sControllersLB'
var lbFrontEndName = projectNameAbbrv
var lbBackendPoolName = 'k8sControllersPool'
var lbProbeName = projectNameAbbrv
var workers = [ 'worker-1', 'worker-2', 'worker-3' ]
var controllers = [ 'controller-1', 'controller-2', 'controller-3' ]

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: projectNameAbbrv
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource loadBalancerIpAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: projectNameAbbrv
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: '${projectNameAbbrv}-cw'
    }
  }
  sku: {
    name: 'Standard'
  }
}

resource loadBalancer 'Microsoft.Network/loadBalancers@2021-08-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
    {
        name: lbFrontEndName
        properties: {
          publicIPAddress: {
            id: loadBalancerIpAddress.id
          }
        }
      }
    ]
    backendAddressPools: [
    {
        name: lbBackendPoolName
      }
    ]
    loadBalancingRules: [
    {
        name: 'inboundRule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, lbFrontEndName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, lbBackendPoolName)
          }
          frontendPort: 6443
          backendPort: 6443
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          protocol: 'Tcp'
          loadDistribution: 'Default'
          disableOutboundSnat: true
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, lbProbeName)
          }
        }
      }
    ]
    probes: [
    {
        name: lbProbeName
        properties: {
          protocol: 'Tcp'
          port: 6443
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource ansible 'Microsoft.Compute/sshPublicKeys@2023-03-01' = {
  name: projectNameAbbrv
  location: location
  properties: {
    publicKey: sshPublicKey
  }
}

module network './modules/vnet/main.bicep' = {
  name: '${deployment().name}-network'
  params: {
    location: location
    networkName: projectNameAbbrv
    vnetAddressPrefixes: '10.0.0.0/8'
    subnetAddressPrefixes: '10.240.0.0/24'
    podCidrPrefixes: '10.200.0.0/16'
    routeTableId: routeTable.id
  }
}

module controller './modules/vm/main.bicep' = [for (controller, index) in controllers: {
  name: '${deployment().name}-${controller}'
  params: {
    instanceName: controller
    publicKey: ansible.properties.publicKey
    location: location
    privateIp: '10.240.0.1${index}'
    subnet: network.outputs.subnetId
    loadBalancerBackendPool: lbBackendPoolName
    loadBalancer: lbName
    tags: {
      Project: 'kubernetes-the-hard-way'
      Role: 'controller'
    }
  }
}]

module worker './modules/vm/main.bicep' = [for (worker, index) in workers: {
  name: '${deployment().name}-${worker}'
  params: {
    instanceName: worker
    publicKey: ansible.properties.publicKey
    location: location
    privateIp: '10.240.0.2${index}'
    subnet: network.outputs.subnetId
    tags: {
      Porject: 'kubernetes-the-hard-way'
      Role: 'worker'
    }
  }
}]

resource routeTable 'Microsoft.Network/routeTables@2023-04-01' = {
  name: projectNameAbbrv
  location: location
}

resource route 'Microsoft.Network/routeTables/routes@2023-04-01' = [for (worker, index) in workers: {
  name: worker
  parent: routeTable
  properties: {
    addressPrefix: '10.200.${index}.0/24'
    hasBgpOverride: false
    nextHopIpAddress: '10.240.0.2${index}'
    nextHopType: 'VirtualAppliance'
  }
}]
