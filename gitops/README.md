# GitOps & Argo CD Platform

This directory contains the Helm charts, environment overlays, and Argo CD Application manifests for managing the Task Management microservice platform on Kubernetes / Amazon EKS.

---

## 📁 Directory Layout

```text
gitops/
├── charts/
│   └── microservice/               # Reusable production Helm chart
│       ├── Chart.yaml
│       ├── values.yaml             # Baseline values
│       └── templates/              # Deployment, Service, Ingress (ALB), HPA, SA, ConfigMap
│
├── environments/
│   └── dev/
│       ├── user-service-values.yaml
│       ├── task-service-values.yaml
│       ├── notification-service-values.yaml
│       ├── frontend-values.yaml    # Includes Ingress definition for AWS ALB
│       └── postgres.yaml           # Dev database deployment
│
└── argo-apps/
    ├── root-application.yaml       # Argo CD "App of Apps" root manifest
    ├── dev-apps.yaml               # Argo CD Application CRDs for all microservices
    └── cluster-addons.yaml         # Argo CD Application for Metrics Server
```

---

## 🚀 Bootstrapping Argo CD on Amazon EKS

### 1. Install Argo CD into the EKS Cluster
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD components to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### 2. Access the Argo CD UI
```bash
# Port-forward to your local machine
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
Open [https://localhost:8080](https://localhost:8080) in your browser (Username: `admin`).

### 3. Deploy the Root App-of-Apps
Ensure `root-application.yaml` points to your GitHub repository URL, then run:

```bash
kubectl apply -f gitops/argo-apps/root-application.yaml
```

Argo CD will automatically detect `gitops/argo-apps/`, create the `taskapp-dev` namespace, deploy all microservices and database via Helm, and maintain live self-healing sync.
