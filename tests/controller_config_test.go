package main

import (
	"testing"
)

func TestControllerConfig(t *testing.T) {
	for _, tt := range controller_tests {
		vm, err := vmFromName(tt.vmName)
		check(err, "Unable to get VM from name")

		pemFiles := []string{
			"ca.pem",
			"kubernetes-key.pem",
			"kubernetes.pem",
			"service-account-key.pem",
			"service-account.pem",
			"admin.kubeconfig",
			"kube-controller-manager.kubeconfig",
			"kube-scheduler.kubeconfig",
			"encryption-config.yaml",
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
