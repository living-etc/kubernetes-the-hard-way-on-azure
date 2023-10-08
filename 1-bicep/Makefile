all: create-resources

create-resources: create-resource-group
	az deployment group create --name KubernetesTheHardWay-$$(date date +"%Y-%m-%d_%H-%M-%S") --template-file resources.bicep --resource-group Kubernetes-The-Hard-Way

create-resource-group:
	az deployment sub create --name KubernetesTheHardWay-$$(date date +"%Y-%m-%d_%H-%M-%S") --template-file resource-group.bicep --location uksouth 

what-if:
	az deployment group what-if --name KubernetesTheHardWay --resource-group Kubernetes-The-Hard-Way --template-file resources.bicep

clean:
	az group delete --resource-group Kubernetes-The-Hard-Way
