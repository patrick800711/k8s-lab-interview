# Create KinD Cluster
KIND_CLUSTER_NAME := lab
KIND_CONFIG := ./kind.yaml

.PHONY: create_cluster bootstrap_cluster clean scenario
all: create_cluster bootstrap_cluster

create_cluster: 
	@kind create cluster --config=$(KIND_CONFIG) --name=$(KIND_CLUSTER_NAME)

bootstrap_cluster:
	@kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	@echo "Waiting for ingress pods to go ready (this may take a minute) ..."
	@kubectl -n ingress-nginx wait --for=condition=ready pod -l app.kubernetes.io/component=controller --timeout=300s
	@kubectl create namespace nginx
	@kubectl taint nodes $(KIND_CLUSTER_NAME)-worker workload=services:NoSchedule > /dev/null
	@kubectl taint nodes $(KIND_CLUSTER_NAME)-worker2 workload=services:NoSchedule > /dev/null

scenario:
	@kubectl apply -f manifest.yaml
	@cat scenario.md

clean:
	@kind delete cluster --name=$(KIND_CLUSTER_NAME)