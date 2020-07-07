#!/bin/bash

./scripts/1-create-gke-clusters.sh

CLUSTER_READY=$(gcloud container clusters list | grep RUNNING | wc -l)
while [[ "${CLUSTER_READY}" -eq 0 ]]; do
	echo -en "Sleeping 5 secs to give time to cluster to be provisioned...\r"
	sleep 5
	CLUSTER_READY=$(gcloud container clusters list | grep RUNNING | wc -l)
done

./scripts/2-install-istio.sh

export PATH="$PATH:/egym/istio-samples/multicluster-gke/dual-control-plane/istio-1.4.2/bin"

./scripts/3-configure-dns.sh
sleep 90
./scripts/4-deploy-hipstershop.sh

PREFIX=$(cat CLUSTER_PREFIX)
#kubectl config use-context gke_${PROJECT_1}_europe-west1-b_${PREFIX}-dual-cluster1
#kubectl get svc -n istio-system istio-ingressgateway

kubectl config use-context gke_${PROJECT_2}_europe-west1-b_${PREFIX}-dual-cluster2
kubectl get svc -n istio-system istio-ingressgateway

#add HPAs
kubectl config use-context gke_${PROJECT_1}_europe-west1-b_${PREFIX}-dual-cluster1
for i in $(kubectl get deployments -n hipster1 -o jsonpath={.items[*]..metadata.name}); do sed 's/NAME/'$i'/' hpa.yaml > hpa_$i.yaml; kubectl create -n hipster1 -f hpa_$i.yaml; done
kubectl config use-context gke_${PROJECT_2}_europe-west1-b_${PREFIX}-dual-cluster2
for i in $(kubectl get deployments -n hipster2 -o jsonpath={.items[*]..metadata.name}); do sed 's/NAME/'$i'/' hpa.yaml > hpa_$i.yaml; kubectl create -n hipster2 -f hpa_$i.yaml; done

#./scripts/cleanup-delete-clusters.sh
