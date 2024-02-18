package main

import (
	"testing"

	"github.com/living-etc/go-server-test/ssh"
)

func TestControllerConfig(t *testing.T) {
	for _, tt := range controller_tests {
		sshclient, err := ssh.NewSshClient(privateKey, tt.hostname)
		check(err, "Unable to get VM from name")

		hostname := sshclient.Hostname()
		if hostname != tt.vmName {
			t.Errorf("wanted %v, got %v", tt.vmName, hostname)
		}

		etcdFiles := []string{
			"/etc/etcd/ca.pem",
			"/etc/etcd/kubernetes-key.pem",
			"/etc/etcd/kubernetes.pem",
		}

		for _, file := range etcdFiles {
			t.Run(tt.vmName+" has "+file, func(t *testing.T) {
				hasFile := sshclient.HasFile(file)
				if !hasFile {
					t.Errorf("%v does not have %v", tt.vmName, file)
				}
			})
		}

		serviceNames := []string{
			"etcd",
			"kube-apiserver",
			"kube-controller-manager",
			"kube-scheduler",
		}

		for _, serviceName := range serviceNames {
			t.Run(tt.vmName+": service "+serviceName+" is running", func(t *testing.T) {
				service, _ := sshclient.Service(serviceName)
				got := service.Active
				want := "active (running)"

				if got != want {
					t.Errorf("wanted %v, got %v", want, got)
				}
			})
		}
	}
}
