package main

import (
	"testing"
)

func TestControllerConfig(t *testing.T) {
	for _, tt := range controller_tests {
		vm, err := vmFromName(tt.vmName)
		check(err, "Unable to get VM from name")

		hostname := vm.hostname()
		if hostname != tt.vmName {
			t.Errorf("wanted %v, got %v", tt.vmName, hostname)
		}

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

		etcdFiles := []string{
			"/etc/etcd/ca.pem",
			"/etc/etcd/kubernetes-key.pem",
			"/etc/etcd/kubernetes.pem",
		}

		for _, file := range etcdFiles {
			t.Run(tt.vmName+" has "+file, func(t *testing.T) {
				hasFile := vm.hasFile(file)
				if !hasFile {
					t.Errorf("%v does not have %v", tt.vmName, file)
				}
			})
		}
	}
}
