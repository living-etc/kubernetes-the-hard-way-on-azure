package main

import (
	"testing"

	"github.com/living-etc/go-server-test/ssh"
)

func TestWorkerConfig(t *testing.T) {
	for _, tt := range worker_tests {
		sshclient, err := ssh.NewSshClient(privateKey, tt.hostname)
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
				hasFile := sshclient.HasFile(file)
				if !hasFile {
					t.Errorf("%v does not have %v", tt.vmName, file)
				}
			})
		}

		binaries := []string{
			"/usr/local/bin/kube-proxy",
			"/usr/local/bin/kubelet",
			"/usr/local/bin/kubectl",
			"/usr/local/bin/runc",
			"/usr/local/bin/crictl",
			"/bin/containerd",
			"/bin/containerd-shim",
			"/bin/containerd-shim-runc-v1",
			"/bin/containerd-shim-runc-v2",
			"/bin/ctr",
		}

		for _, file := range binaries {
			t.Run(tt.vmName+": "+file, func(t *testing.T) {
				file, _ := sshclient.File(file)

				if file.OwnerName != "root" {
					t.Errorf("want %v, got %v", "root", file.OwnerName)
				}

				if file.Mode != "0755" {
					t.Errorf("want %v, got %v", "0755", file.Mode)
				}
			})
		}
	}
}
