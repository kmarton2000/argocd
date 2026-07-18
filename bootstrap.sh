#!/bin/bash

set -e

cd argocd

echo "Updating Helm dependencies..."
helm dependency update

echo "Installing/updating ArgoCD..."
microk8s helm3 upgrade --install argocd . \
    --namespace argocd \
    --create-namespace

echo
echo "Initial password:"
#microk8s kubectl -n argocd get secret argocd-initial-admin-secret \
#    -o jsonpath="{.data.password}" | base64 -d
echo