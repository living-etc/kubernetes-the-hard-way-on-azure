package main

import (
	"fmt"
	"testing"

	"github.com/living-etc/go-server-test/ssh"
)

func TestWorkerConfig(t *testing.T) {
	for _, tt := range worker_tests {
		sshclient, err := ssh.NewSshClient(privateKey, tt.hostname)
		check(err, "Unable to get VM from name")

		binaries := []string{
			"/usr/local/bin/kube-proxy",
			"/usr/local/bin/kubelet",
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

		serviceNames := []string{
			"kubelet",
			"kube-proxy",
			"containerd",
		}

		for _, serviceName := range serviceNames {
			t.Run(tt.vmName+": "+serviceName, func(t *testing.T) {
				service, _ := sshclient.Service(serviceName)

				if service.Enabled != "enabled" {
					t.Errorf("want %v, got %v", "enabled", service.Enabled)
				}

				if service.Active != "active (running)" {
					t.Errorf("want %v, got %v", "active (running)", service.Active)
				}
			})
		}

		cniPlugins := []string{
			"bandwidth",
			"bridge",
			"dhcp",
			"firewall",
			"host-device",
			"host-local",
			"ipvlan",
			"loopback",
			"macvlan",
			"portmap",
			"ptp",
			"sbr",
			"static",
			"tuning",
			"vlan",
			"vrf",
		}

		for _, cniPlugin := range cniPlugins {
			t.Run(tt.vmName+" has cni binary "+cniPlugin, func(t *testing.T) {
				file, err := sshclient.File(fmt.Sprintf("/opt/cni/bin/%v", cniPlugin))
				if err != nil {
					t.Error(err)
				}
				modeGot := file.Mode
				modeWant := "0755"

				if modeGot != modeWant {
					t.Errorf("want %v, got %v", modeWant, modeGot)
				}
			})
		}

		configFiles := []string{
			"/etc/containerd/config.toml",
			"/var/lib/kubelet/kubelet-config.yaml",
			"/etc/cni/net.d/10-containerd-net.conflist",
			"/var/lib/kube-proxy/kubeconfig",
			"/var/lib/kubelet/kubeconfig",
			"/var/lib/kubernetes/ca.pem",
			fmt.Sprintf("/var/lib/kubelet/%v-key.pem", tt.vmName),
			fmt.Sprintf("/var/lib/kubelet/%v.pem", tt.vmName),
		}

		for _, configFile := range configFiles {
			t.Run(tt.vmName+" has config file "+configFile, func(t *testing.T) {
				_, err := sshclient.File(configFile)
				if err != nil {
					t.Error(err)
				}
			})
		}
	}
}
