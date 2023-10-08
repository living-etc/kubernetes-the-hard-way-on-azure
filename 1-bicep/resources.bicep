targetScope = 'resourceGroup'

param location string = resourceGroup().location

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
}

resource ansible 'Microsoft.Compute/sshPublicKeys@2023-03-01' = {
  name: projectNameAbbrv
  location: location
  properties: {
    publicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCsMcNp3C6lW65QJb6EGNAyioWHMZF7RALFiZGAiPZP1q7gG/FrfykngdG5m056HM1e4sHXKtVZvK0XQ3AUij6R+Mjos3I91Fka58P6AfuTQLhexMeid61qPT015jAsNmcRXyBkAivzQulDjvI/erK1PYX2bCPy9+KczslrYDMrn5VdCE3nCQNk4OyETBA4qkCJE21AG0eqgOd2lMUmH53Zcon3FmW+K12FL7svRYHfcuQ2/LBIr1KAa5ZR38+DaLja0b46Mi5SZcjhmGHAMip7miZzux6E5BgzeCEjjRnTBtUC1FIS8dz3QaUMHhOIFONn/6br7pmAZk1qidsJzzt255uITiwUBvRuCBLQ62gHaeJwnKQbUSVLRxc7XVrjR/+hK7gXmWCOHlaA4pErO7dmn2NS0enxIAgSy0Q9QQ2CIrycFwo0WDwQ9yGTMjoVaFcm+ETNjGvBRGN4ODNRNCZ9+q61JHwNY0aoEy0OCPSZPH+SetpyYb54M5Bldy7VeVE= ansible@kubernetes-the-hard-way'
  }
}

module network './modules/vnet/main.bicep' = {
  name: projectNameAbbrv
  params: {
    location: location
    networkName: projectNameAbbrv
    vnetAddressPrefixes: '10.240.0.0/24'
    subnetAddressPrefixes: '10.240.0.0/24'
  }
}

module controller './modules/vm/main.bicep' = [for index in range(0, 3): {
  name: 'controller-${index}'
  params: {
    instanceName: 'controller-${index}'
    publicKey: ansible.properties.publicKey
    location: location
    privateIp: '10.240.0.1${index}'
    subnet: network.outputs.subnetId
    tags: {
      Porject: 'kubernetes-the-hard-way'
      Role: 'controller'
    }
  }
}]

module worker './modules/vm/main.bicep' = [for index in range(0, 3): {
  name: 'worker-${index}'
  params: {
    instanceName: '${projectNameAbbrv}-worker-${index}'
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
