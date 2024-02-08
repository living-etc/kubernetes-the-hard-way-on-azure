include tasks/Makefile.compute
include tasks/Makefile.tls
include tasks/Makefile.kubeconfig
include tasks/Makefile.provision

default: all
all: compute/all tls/all kubeconfig/all provision/all
clean: compute/clean tls/clean kubeconfig/clean
test: compute/test provision/test
