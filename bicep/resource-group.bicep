targetScope = 'subscription'

param location string = deployment().location

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'Kubernetes-The-Hard-Way'
  location: location
  tags: {
    Project: 'Kubernetes-The-Hard-Way'
  }
}
