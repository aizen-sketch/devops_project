# CloudOps Task Management Platform (Microservices)

An enterprise-ready sample microservices application designed for learning DevOps, GitOps, Kubernetes (EKS), Helm, Argo CD, and CI/CD pipelines.

---

## 🏗️ Architecture Overview

The application is decomposed into four decoupled components:

| Service | Port | Technology | Responsibilities |
| :--- | :--- | :--- | :--- |
| **`user-service`** | `3001` | Node.js / Express / Postgres | Manages user profiles, team members, and roles. Exposes `/healthz`, `/readyz`, and `/metrics`. |
| **`task-service`** | `3002` | Node.js / Express / Postgres | Handles CRUD for tasks. Validates users with `user-service` and emits notification events. Exposes `/healthz`, `/readyz`, and `/metrics`. |
| **`notification-service`**| `3003` | Node.js / Express | Ingests async events (e.g. task created, status updated), logs alerts, and tracks notifications. Exposes `/metrics`. |
| **`frontend`** | `3000` | HTML5 / Express Gateway | Single-page Kanban board and API Gateway reverse proxy routing requests to backend services. |
| **`postgres`** | `5432` | PostgreSQL 16 | Relational data store with isolated databases (`taskapp_user`, `taskapp_task`). |

---

## 🚀 Running Locally with Docker Compose

To spin up all services and the database with automated health checks:

```bash
cd app
docker compose up --build
```

Access the application:
- **Web UI Dashboard**: [http://localhost:3000](http://localhost:3000)
- **User Service API**: [http://localhost:3001/api/users](http://localhost:3001/api/users)
- **Task Service API**: [http://localhost:3002/api/tasks](http://localhost:3002/api/tasks)
- **Notification Service API**: [http://localhost:3003/api/notifications](http://localhost:3003/api/notifications)

---

## 📊 Observability & Kubernetes Probes

Every backend service is configured with Kubernetes-native endpoints:

- **Liveness Probe**: `GET /healthz` (returns `200 OK` if the process is alive)
- **Readiness Probe**: `GET /readyz` (returns `200 OK` if database connections and dependencies are verified, `503` if not ready)
- **Prometheus Metrics**: `GET /metrics` (exposes standard HTTP latency histograms, error counters, and custom business metrics for HPA autoscaling)

---

## 🔒 Enterprise Container Security Best Practices

The included `Dockerfile`s implement:
1. **Multi-stage builds**: Only production dependencies are bundled into the final image.
2. **Non-root execution**: Runs under user `node` (UID 1000) instead of `root`.
3. **Built-in container healthchecks**: Enables Docker daemon and ECS/Kubernetes runtime to detect unhealthy containers.
4. **Minimal attack surface**: Built on Alpine Linux base images.
