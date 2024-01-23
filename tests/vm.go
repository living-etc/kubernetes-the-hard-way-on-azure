package main

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strconv"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/compute/armcompute"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/network/armnetwork/v2"
	"golang.org/x/crypto/ssh"
)

type VM struct {
	privateIPAddress string
	publicIPAddress  string
	dnsName          string
}

func check(err error, message string) {
	if err != nil {
		log.Fatalf("%v: %v", message, err)
	}
}

func (vm VM) reachableOnPort(port int) (bool, error) {
	cmd := exec.Command("nc", vm.publicIPAddress, strconv.Itoa(port), "-w 1")

	_, err := cmd.Output()
	if err != nil {
		return false, errors.New("non-zero exit code from nc: " + err.Error())
	}

	return true, nil
}

func (vm VM) newSSHSession() (*ssh.Client, error) {
	key, err := os.ReadFile("../keys/id_rsa")
	check(err, "Unable to read private key file")

	signer, err := ssh.ParsePrivateKey(key)
	check(err, "Unable to parse private key file")

	config := &ssh.ClientConfig{
		User: "ubuntu",
		Auth: []ssh.AuthMethod{
			ssh.PublicKeys(signer),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	client, err := ssh.Dial("tcp", vm.publicIPAddress+":22", config)

	return client, err
}

func (vm VM) connectableOverSSH(publicKeyPath string) (bool, error) {
	client, err := vm.newSSHSession()
	check(err, "Unable to connect to "+vm.publicIPAddress)
	defer client.Close()

	return true, nil
}

func (vm VM) hasFile(filename string) bool {
	client, err := vm.newSSHSession()
	check(err, "Unable to connect to "+vm.publicIPAddress)

	session, err := client.NewSession()
	check(err, "Unable to open SSH session")
	defer session.Close()

	cmd := fmt.Sprintf("test -f %v", filename)
	err = session.Run(cmd)

	if err != nil {
		return false
	}

	return true
}

func vmFromName(name string) (VM, error) {
	var result VM

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	check(err, "Failed to get OAuth config")
	ctx := context.Background()

	vmClient, err := armcompute.NewVirtualMachinesClient(subscriptionId, credential, nil)
	check(err, "Failed to get compute client")

	vm, err := vmClient.Get(ctx, resourceGroupName, name, nil)
	check(err, "Could not retrieve instance view")

	nicRef := vm.Properties.NetworkProfile.NetworkInterfaces[0]
	nicID, err := arm.ParseResourceID(*nicRef.ID)
	check(err, "Unable to parse nic resource id")

	nicClient, err := armnetwork.NewInterfacesClient(subscriptionId, credential, nil)
	check(err, "Unable to get network interfaces client")

	nic, err := nicClient.Get(ctx, resourceGroupName, nicID.Name, nil)
	check(err, "Unable to get nic")

	for _, ipConfig := range nic.Properties.IPConfigurations {
		if ipAddress := ipConfig.Properties.PrivateIPAddress; ipAddress != nil {
			result.privateIPAddress = *ipAddress
		}
		if ipAddress := ipConfig.Properties.PublicIPAddress; ipAddress != nil {
			publicIPClient, err := armnetwork.NewPublicIPAddressesClient(
				subscriptionId,
				credential,
				nil,
			)
			check(err, "Could not initialise the public ip client")

			publicIPID, err := arm.ParseResourceID(*ipAddress.ID)
			check(err, "Could not parse the public ID resource ID")

			publicIP, err := publicIPClient.Get(ctx, resourceGroupName, publicIPID.Name, nil)
			check(err, "Could not get public IP address")

			result.publicIPAddress = *publicIP.PublicIPAddress.Properties.IPAddress
			result.dnsName = *publicIP.PublicIPAddress.Properties.DNSSettings.Fqdn
		}
	}

	return result, nil
}
