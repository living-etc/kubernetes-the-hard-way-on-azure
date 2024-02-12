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

		t.Run(tt.vmName+" correct DNS name", func(t *testing.T) {
			want := tt.vmName + "-kthw-cw.uksouth.cloudapp.azure.com"
			got := vm.DnsName
			if got != want {
				t.Errorf("want %v, got %v", want, got)
			}
		})
	}
}
