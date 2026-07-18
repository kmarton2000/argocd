microk8s kubectl create namespace argocd
microk8s kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
microk8s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
microk8s kubectl port-forward service/argocd-server 8080:443 -n argocd