CONTAINER_CLI=docker

IMAGE_REGISTRY=index.docker.io
IMAGE_REPOSTIRY=bluebrown/argocd-cmp-kpt
IMAGE_TAG=v1.0.0-beta.21

img=$(IMAGE_REGISTRY)/$(IMAGE_REPOSTIRY)


# this cool help text is from https://github.com/kubernetes-sigs/kubebuilder. Thank you :)
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Build

.PHONY: build
build: ## Build the container image
	$(CONTAINER_CLI) build --tag $(img):latest --tag $(img):$(IMAGE_TAG) plugin/

.PHONY: push
push: ## Push the container image
	$(CONTAINER_CLI) push $(img):$(IMAGE_TAG)
	$(CONTAINER_CLI) push $(img):latest


##@ Deployment

.PHONY: install
install: ## Install ArgoCD with CMP into the argocd namespace
	kubectl create ns argocd --dry-run=client --output yaml | kubectl apply --filename -
	kustomize build configuration/ | kubectl apply --filename -

.PHONY: uninstall
uninstall: ## Remove all ArgoCD resources from the argocd namespace and delete the namespace
	kustomize build configuration/ | kubectl delete --ignore-not-found --filename -
	kubectl delete ns argocd --ignore-not-found
