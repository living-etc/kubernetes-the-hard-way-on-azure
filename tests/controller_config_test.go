package main

import (
	"fmt"
	"strings"
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
				hasFile := sshclient.HasFile(file)
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
				hasFile := sshclient.HasFile(file)
				if !hasFile {
					t.Errorf("%v does not have %v", tt.vmName, file)
				}
			})
		}

		services := []string{
			"etcd",
		}

		for _, service := range services {
			t.Run(tt.vmName+": service "+service+" is running", func(t *testing.T) {
				got := sshclient.Service(service).IsActive
				want := "active"

				if got != want {
					t.Errorf("wanted %v, got %v", want, got)
				}
			})
		}

		if tt.vmName == "controller-1" {
			t.Run(tt.vmName+": etcd member list", func(t *testing.T) {
				command := `sudo ETCDCTL_API=3 etcdctl member list \
        --endpoints=https://127.0.0.1:2379 \
        --cacert=/etc/etcd/ca.pem \
        --cert=/etc/etcd/kubernetes.pem \
        --key=/etc/etcd/kubernetes-key.pem`

				got := sshclient.Command(command)

				for _, member := range controller_tests {
					t.Run(tt.vmName+": etcd member", func(t *testing.T) {
						memberName := member.vmName
						want := fmt.Sprintf("started, %v", memberName)

						if !strings.Contains(got, want) {
							t.Errorf("%v not a member of etcd cluster: %v", memberName, got)
						}
					})
				}
			})
		}
	}
}
