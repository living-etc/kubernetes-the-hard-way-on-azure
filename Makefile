include tasks/Makefile.bicep
include tasks/Makefile.tls
include tasks/Makefile.provision

default: all
all: bicep/all tls/all provision/all
clean: bicep/clean tls/clean

ips:
	./scripts/get-ips.sh

test:
	cd tests; go test
