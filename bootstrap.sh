#!/bin/bash

set -e

cd argocd

echo "Updating Helm dependencies..."
helm dependency update

echo "Installing/updating ArgoCD..."
microk8s helm3 upgrade --install argocd . \
    --namespace argocd \
    --create-namespace

echo "Waiting for ArgoCD pods to become Ready..."
microk8s kubectl rollout status deployment/argocd-server \
    -n argocd --timeout=300s

microk8s kubectl rollout status deployment/argocd-repo-server \
    -n argocd --timeout=300s

microk8s kubectl rollout status deployment/argocd-applicationset-controller \
    -n argocd --timeout=300s

microk8s kubectl rollout status deployment/argocd-dex-server \
    -n argocd --timeout=300s

microk8s kubectl rollout status deployment/argocd-redis \
    -n argocd --timeout=300s

microk8s kubectl rollout status statefulset/argocd-application-controller \
    -n argocd --timeout=300s

echo
echo "Initial password:"
microk8s kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d
echo