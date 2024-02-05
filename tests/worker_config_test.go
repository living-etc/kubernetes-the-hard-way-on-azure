package main

import (
	"testing"
)

func TestWorkerConfig(t *testing.T) {
	for _, tt := range worker_tests {
		vm, err := vmFromName(tt.vmName)
		check(err, "Unable to get VM from name")

		pemFiles := []string{
			"ca.pem",
			tt.vmName + "-key.pem",
			tt.vmName + ".pem",
			tt.vmName + ".kubeconfig",
			"kube-proxy.kubeconfig",
		}

		for _, file := range pemFiles {
			t.Run(tt.vmName+" has "+file, func(t *testing.T) {
				hasFile := vm.hasFile(file)
				if !hasFile {
					t.Errorf("%v does not have %v", tt.vmName, file)
				}
			})
		}
	}
}
