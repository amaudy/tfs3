.PHONY: fmt validate test clean

fmt:
	terraform fmt -recursive

validate:
	cd examples/simple && terraform init -backend=false && terraform validate
	cd examples/complete && terraform init -backend=false && terraform validate

test:
	cd test && go mod tidy && AWS_PROFILE=${AWS_PROFILE} go test -v

terratest-clean:
	cd test && go clean -testcache

clean: terratest-clean
	find . -type d -name ".terraform" -exec rm -rf {} +
	find . -type f -name ".terraform.lock.hcl" -delete
	find . -type f -name "terraform.tfstate*" -delete

all: fmt validate test