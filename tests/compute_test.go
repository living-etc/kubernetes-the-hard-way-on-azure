package main

import (
	"testing"
)

func TestCompute(t *testing.T) {
	for _, tt := range all_tests {
		vm, err := azureclient.VmFromName(tt.vmName)
		check(err, "Unable to get VM from name")

		t.Run(tt.vmName+" correct private IP", func(t *testing.T) {
			if vm.PrivateIPAddress != tt.privateIP {
				t.Errorf("Want %v, got %v", tt.privateIP, vm.PrivateIPAddress)
			}
		})

		reachable, err := vm.ReachableOnPort(22)
		check(err, "Unable to check reachability of VM on port 22")
		t.Run(tt.vmName+" reachable on port 22", func(t *testing.T) {
			if !reachable {
				t.Errorf("%v: not reachable on port 22", tt.vmName)
			}
		})

		connectable, err := vm.ConnectableOverSSH("../0-keys/id_rsa.pub")
		check(err, "Unable to check SSH connectivity")
		t.Run(tt.vmName+" connectable over SSH", func(t *testing.T) {
			if !connectable {
				t.Errorf("%v: not connectable over ssh", tt.vmName)
			}
		})

		t.Run(tt.vmName+" correct DNS name", func(t *testing.T) {
			want := tt.vmName + "-kthw-cw.uksouth.cloudapp.azure.com"
			got := vm.DnsName
			if got != want {
				t.Errorf("want %v, got %v", want, got)
			}
		})
	}
}
