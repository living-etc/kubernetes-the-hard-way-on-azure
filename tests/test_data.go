package main

const (
	subscriptionId    = "767c436e-682c-42c0-88f5-66d53a80176d"
	resourceGroupName = "kubernetes-the-hard-way"
)

var tests = []struct {
	vmName    string
	privateIP string
}{
	{
		vmName:    "controller-1",
		privateIP: "10.240.0.11",
	},
	{
		vmName:    "controller-2",
		privateIP: "10.240.0.12",
	},
	{
		vmName:    "controller-3",
		privateIP: "10.240.0.13",
	},
	{
		vmName:    "worker-1",
		privateIP: "10.240.0.21",
	},
	{
		vmName:    "worker-2",
		privateIP: "10.240.0.22",
	},
	{
		vmName:    "worker-3",
		privateIP: "10.240.0.23",
	},
}
