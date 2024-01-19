package main

import (
	"context"
	"log"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/compute/armcompute"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v2"
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

func privateIPFromVM(vmName string) (string, error) {
	credential, err := azidentity.NewDefaultAzureCredential(nil)
	check(err, "Failed to get OAuth config")
	ctx := context.Background()

	vmClient, err := armcompute.NewVirtualMachinesClient(subscriptionId, credential, nil)
	check(err, "Failed to get compute client")

	vm, err := vmClient.Get(ctx, resourceGroupName, vmName, nil)
	check(err, "Could not retrieve instance view")

	nicRef := vm.Properties.NetworkProfile.NetworkInterfaces[0]
	nicID, err := arm.ParseResourceID(*nicRef.ID)
	check(err, "Unable to parse nic resource id")

	nicClient, err := armnetwork.NewInterfacesClient(subscriptionId, credential, nil)
	check(err, "Unable to get network interfaces client")

	nic, err := nicClient.Get(ctx, resourceGroupName, nicID.Name, nil)
	check(err, "Unable to get nic")

	var privateIPAddress string
	for _, ipConfig := range nic.Properties.IPConfigurations {
		if ipAddress := ipConfig.Properties.PrivateIPAddress; ipAddress != nil {
			privateIPAddress = *ipAddress
			break
		}
	}

	return privateIPAddress, nil
}

func TestVMs(t *testing.T) {
	tests := []struct {
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

	for _, tt := range tests {
		privateIPAddress, err := privateIPFromVM(tt.vmName)
		check(err, "Unable to get private IP from VM")

		t.Run(tt.vmName+" correct private IP", func(t *testing.T) {
			if privateIPAddress != tt.privateIP {
				t.Errorf("Want %v, got %v", tt.privateIP, privateIPAddress)
			}
		})
	}
}
