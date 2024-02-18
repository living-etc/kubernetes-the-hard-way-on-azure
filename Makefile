include tasks/Makefile.compute
include tasks/Makefile.tls
include tasks/Makefile.kubeconfig
include tasks/Makefile.provision
include tasks/Makefile.kubernetes

default: all
all: compute/all tls/all kubeconfig/all provision/all kubernetes/all
clean: compute/clean tls/clean kubeconfig/clean
test: compute/test provision/test kubernetes/test
