package main

import (
	"log"

	"github.com/living-etc/go-server-test/azure"
)

const (
	subscriptionId    = "767c436e-682c-42c0-88f5-66d53a80176d"
	resourceGroupName = "kubernetes-the-hard-way"
)

func check(err error, message string) {
	if err != nil {
		log.Fatalf("%v: %v", message, err)
	}
}

var azureclient = azure.NewAzureClient(subscriptionId, resourceGroupName)

var all_tests = append(worker_tests, controller_tests...)

var worker_tests = []struct {
	vmName    string
	privateIP string
}{
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

var controller_tests = []struct {
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
}
