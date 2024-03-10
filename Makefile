include tasks/Makefile.compute
include tasks/Makefile.tls
include tasks/Makefile.kubeconfig
include tasks/Makefile.provision
include tasks/Makefile.kubernetes

default: all
all: compute/all tls/all kubeconfig/all provision/all kubernetes/all
clean: compute/clean tls/clean kubeconfig/clean
test: compute/test provision/test kubernetes/test

WORKERS=worker-1 worker-2 worker-3
CONTROLLERS=controller-1 controller-2 controller-3

status/kube-proxy:
	@$(foreach WORKER,$(WORKERS),ssh $(WORKER) -C 'sudo systemctl status kube-proxy';)

status/kubelet:
	@$(foreach WORKER,$(WORKERS),ssh $(WORKER) -C 'sudo systemctl status kubelet';)

status/kube-apiserver:
	@$(foreach CONTROLLER,$(CONTROLLERS),ssh $(CONTROLLER) -C 'sudo systemctl status kube-apiserver';)
