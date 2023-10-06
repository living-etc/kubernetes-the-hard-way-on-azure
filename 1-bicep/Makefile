create-resource-group:
	az group create --name Kubernetes-The-Hard-Way --location uksouth

create-resources:
	az deployment group create --name KubernetesTheHardWay --resource-group Kubernetes-The-Hard-Way --template-file main.bicep

what-if:
	az deployment group what-if --name KubernetesTheHardWay --resource-group Kubernetes-The-Hard-Way --template-file main.bicep

delete:
	az group delete --resource-group Kubernetes-The-Hard-Way
