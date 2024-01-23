include tasks/Makefile.compute
include tasks/Makefile.tls
include tasks/Makefile.config

default: all
all: compute/all tls/all config/all
clean: compute/clean tls/clean

ips:
	./scripts/get-ips.sh

test:
	cd tests; go test
