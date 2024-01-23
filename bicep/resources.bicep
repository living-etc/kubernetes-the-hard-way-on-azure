targetScope = 'resourceGroup'

param location string = resourceGroup().location
param sshPublicKey string

var projectNameAbbrv = 'kthw'

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
  sku: {
    name: 'Basic'
    tier: 'Regional'
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
    vnetAddressPrefixes: '10.240.0.0/24'
    subnetAddressPrefixes: '10.240.0.0/24'
  }
}

module controller './modules/vm/main.bicep' = [for index in range(1, 3): {
  name: '${deployment().name}-controller-${index}'
  params: {
    instanceName: 'controller-${index}'
    publicKey: ansible.properties.publicKey
    location: location
    privateIp: '10.240.0.1${index}'
    subnet: network.outputs.subnetId
    tags: {
      Project: 'kubernetes-the-hard-way'
      Role: 'controller'
    }
  }
}]

module worker './modules/vm/main.bicep' = [for index in range(1, 3): {
  name: '${deployment().name}-worker-${index}'
  params: {
    instanceName: 'worker-${index}'
    publicKey: ansible.properties.publicKey
    location: location
    privateIp: '10.240.0.2${index}'
    customData: '{"pod-cidr":"10.200.${index}.0/24"}'
    subnet: network.outputs.subnetId
    tags: {
      Porject: 'kubernetes-the-hard-way'
      Role: 'worker'
    }
  }
}]
