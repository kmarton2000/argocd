#!/bin/bash

cd argocd

echo "Uninstalling ArgoCD..."
microk8s helm3 uninstall argocd --namespace argocd

echo "Deleting ArgoCD CRDs..."
microk8s kubectl delete crd \
    applications.argoproj.io \
    applicationsets.argoproj.io \
    appprojects.argoproj.io