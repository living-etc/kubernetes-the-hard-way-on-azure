package main

import (
	"log"
	"os"

	"github.com/living-etc/go-server-test/azure"
)

const (
	subscriptionId     = "767c436e-682c-42c0-88f5-66d53a80176d"
	resourceGroupName  = "kubernetes-the-hard-way"
	privateKeyFilePath = "../keys/id_rsa"
	loadBalancerHost   = "https://kthw-cw.uksouth.cloudapp.azure.com"
)

func check(err error, message string) {
	if err != nil {
		log.Fatalf("%v: %v", message, err)
	}
}

var (
	azureclient   = azure.NewAzureClient(subscriptionId, resourceGroupName)
	privateKey, _ = os.ReadFile(privateKeyFilePath)
)

var all_tests = append(worker_tests, controller_tests...)

type Node struct {
	vmName    string
	privateIP string
	hostname  string
}

var worker_tests = []Node{
	{
		vmName:    "worker-1",
		privateIP: "10.240.0.21",
		hostname:  "worker-1-kthw-cw.uksouth.cloudapp.azure.com",
	},
	{
		vmName:    "worker-2",
		privateIP: "10.240.0.22",
		hostname:  "worker-2-kthw-cw.uksouth.cloudapp.azure.com",
	},
	{
		vmName:    "worker-3",
		privateIP: "10.240.0.23",
		hostname:  "worker-3-kthw-cw.uksouth.cloudapp.azure.com",
	},
}

var controller_tests = []Node{
	{
		vmName:    "controller-1",
		privateIP: "10.240.0.11",
		hostname:  "controller-1-kthw-cw.uksouth.cloudapp.azure.com",
	},
	{
		vmName:    "controller-2",
		privateIP: "10.240.0.12",
		hostname:  "controller-2-kthw-cw.uksouth.cloudapp.azure.com",
	},
	{
		vmName:    "controller-3",
		privateIP: "10.240.0.13",
		hostname:  "controller-3-kthw-cw.uksouth.cloudapp.azure.com",
	},
}
