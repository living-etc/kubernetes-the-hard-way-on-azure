all: create-resources

create-resources: create-resource-group
	az deployment group create \
		--name KubernetesTheHardWay-$(shell date +"%Y-%m-%d_%H-%M-%S") \
		--template-file resources.bicep \
		--resource-group Kubernetes-The-Hard-Way \
		--parameters "sshPublicKey=$(shell cat ../0-keys/id_rsa.pub)"

create-resource-group:
	az deployment sub create \
		--name KubernetesTheHardWay-$(shell date +"%Y-%m-%d_%H-%M-%S") \
		--template-file resource-group.bicep \
		--location uksouth

what-if:
	az deployment group what-if \
		--name KubernetesTheHardWay-$(shell date +"%Y-%m-%d_%H-%M-%S") \
		--template-file resources.bicep \
		--resource-group Kubernetes-The-Hard-Way \
		--parameters "sshPublicKey=$(shell cat ../0-keys/id_rsa.pub)"

clean:
	az group delete \
		--resource-group Kubernetes-The-Hard-Way
