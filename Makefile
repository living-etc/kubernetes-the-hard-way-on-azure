include tasks/Makefile.compute
include tasks/Makefile.tls
include tasks/Makefile.kubeconfig
include tasks/Makefile.config

default: all
all: compute/all tls/all kubeconfig/all config/all
clean: compute/clean tls/clean kubeconfig/clean
test: compute/test config/test
