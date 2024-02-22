package main

import (
	"fmt"
	"strings"
	"testing"

	"github.com/living-etc/go-server-test/kubernetes"
	"github.com/living-etc/go-server-test/ssh"
)

func TestKubernetesConfig(t *testing.T) {
	for _, tt := range controller_tests {
		t.Run(tt.vmName+": etcd member list", func(t *testing.T) {
			command := `sudo ETCDCTL_API=3 etcdctl member list \
                  --endpoints=https://127.0.0.1:2379 \
                  --cacert=/etc/etcd/ca.pem \
                  --cert=/etc/etcd/kubernetes.pem \
                  --key=/etc/etcd/kubernetes-key.pem`

			sshclient, _ := ssh.NewSshClient(privateKey, tt.hostname)
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

	workers, err := kubernetesclient.Workers()
	if err != nil {
		t.Error(err.Error())
	}
	t.Run("number of workers", func(t *testing.T) {
		got := len(workers)
		want := 3
		if got != want {
			t.Errorf("want %v, got %v", want, got)
		}
	})

	t.Run("state of workers", func(t *testing.T) {
		notReadyWorkers := []kubernetes.Worker{}
		for _, worker := range workers {
			if worker.Status != "Ready" {
				notReadyWorkers = append(notReadyWorkers, worker)
			}
		}

		noOfNotReadyWorkers := len(notReadyWorkers)
		if noOfNotReadyWorkers > 0 {
			t.Errorf(
				"%v workers not in READY state: %v",
				noOfNotReadyWorkers,
				notReadyWorkers,
			)
		}
	})

	t.Run("kubernetes version info", func(t *testing.T) {
		kubernetesVersionWant := "1.29"
		kubernetesVersionGot := kubernetesclient.Version().Full

		if kubernetesVersionGot != kubernetesVersionWant {
			t.Errorf("want %v, got %v", kubernetesVersionWant, kubernetesVersionGot)
		}
	})
}
