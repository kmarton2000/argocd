# ArgoCD Helm deployment microk8s környezethez

Ez a repository egy újrahasznosítható Helm alapú konfigurációt tartalmaz az ArgoCD telepítéséhez **microk8s Kubernetes környezetben**.

A cél egy reprodukálható ArgoCD telepítés létrehozása Helm chart segítségével, amely egyszerűen telepíthető, frissíthető és eltávolítható.

## Repository struktúra

```
.
├── README.md
├── argocd
│   ├── Chart.yaml
│   ├── values.yaml
│   └── charts/
├── bootstrap.sh
└── destroy.sh
```

## Helm chart

Az `argocd` könyvtár tartalmazza a Helm chart konfigurációt.

A chart a hivatalos ArgoCD Helm chartot használja dependency-ként.

A Helm chart kezeli:

- ArgoCD komponensek telepítését
- Kubernetes erőforrásokat
- RBAC jogosultságokat
- CRD-k létrehozását
- Ingress konfigurációt

A konfiguráció az alábbi fájlban található:

```
argocd/values.yaml
```

Jelenlegi konfiguráció:

- Namespace: `argocd`
- Domain: `argocd.local`
- Ingress class: `public`
- Service típus: `ClusterIP`
- ArgoCD server insecure mód engedélyezve (Ingress mögötti használathoz)
- ApplicationSet controller engedélyezve
- Notifications kikapcsolva

---

# Telepítés

A telepítéshez futtasd:

```bash
./bootstrap.sh
```

A script a következő lépéseket hajtja végre:

1. Belép az ArgoCD Helm chart könyvtárba.
2. Frissíti a Helm dependency-ket.
3. Telepíti vagy frissíti az ArgoCD Helm release-t.
4. Létrehozza az `argocd` namespace-t, ha szükséges.
5. Kiírja az alapértelmezett admin jelszót.

A telepítés során használt Helm parancs:

```bash
microk8s helm3 upgrade --install argocd . \
    --namespace argocd \
    --create-namespace
```

---

# Elérés

A telepítés után az ArgoCD az Ingress konfiguráción keresztül érhető el:

```
http://argocd.local
```

A domain név feloldásához szükség lehet a kliens gépen egy hosts bejegyzésre.

Linux:

```bash
sudo nano /etc/hosts
```

Példa:

```
192.168.1.76 argocd.local
```

A megfelelő IP cím a microk8s node IP címe.

---

# Admin jelszó lekérése

A bootstrap script automatikusan kiírja az első admin jelszót.

Manuálisan:

```bash
microk8s kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

Felhasználónév:

```
admin
```

---

# Eltávolítás

Az ArgoCD eltávolítása:

```bash
./destroy.sh
```

A script:

1. Törli az ArgoCD Helm release-t.
2. Eltávolítja az ArgoCD CRD-ket.

A CRD-k eltávolítása azért szükséges, mert ezek klaszterszintű Kubernetes erőforrások, és egy újratelepítés során blokkolhatják a Helm release létrehozását.

Manuális eltávolítás:

```bash
microk8s helm3 uninstall argocd --namespace argocd
```

CRD-k törlése:

```bash
microk8s kubectl delete crd \
applications.argoproj.io \
applicationsets.argoproj.io \
appprojects.argoproj.io
```

---

# Manuális telepítés (teszteléshez)

Az ArgoCD közvetlen Kubernetes manifest alkalmazással is telepíthető.

Ez a módszer elsősorban tesztelési célokra ajánlott.

## Namespace létrehozása

```bash
microk8s kubectl create namespace argocd
```

## ArgoCD Kubernetes erőforrások telepítése

```bash
microk8s kubectl apply \
-n argocd \
--server-side \
--force-conflicts \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Admin jelszó lekérése

```bash
microk8s kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

## Port forwarding

Teszteléshez az ArgoCD service továbbítható lokálisan:

```bash
microk8s kubectl port-forward \
service/argocd-server \
8080:443 \
-n argocd
```

Ezután:

```
https://localhost:8080
```

címen érhető el.

Amennyiben a teszt sikeres, ajánlott a port-forward helyett Ingress használata.

---

# Fájlok

## bootstrap.sh

A telepítési folyamat automatizálása.

```bash
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
microk8s kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d
echo
```

---

## destroy.sh

Az ArgoCD Helm release eltávolítása.

```bash
#!/bin/bash

cd argocd

echo "Uninstalling ArgoCD..."

microk8s helm3 uninstall argocd \
    --namespace argocd

echo "Deleting ArgoCD CRDs..."

microk8s kubectl delete crd \
    applications.argoproj.io \
    applicationsets.argoproj.io \
    appprojects.argoproj.io
```

---

# Következő lépések

Lehetséges továbbfejlesztések:

- TLS konfiguráció hozzáadása Ingress mögé.
- Saját ArgoCD felhasználók és RBAC szabályok konfigurálása.
- Git repository alapú alkalmazás deployment kialakítása.
- ArgoCD Application és ApplicationSet objektumok használata.