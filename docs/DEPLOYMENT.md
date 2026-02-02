# Deployment Guide

## Production Deployment

### Docker

```bash
# Build image
docker build -t hermes:latest .

# Run container
docker run -d -p 50051:50051 --name hermes-server hermes:latest
```

### Docker Compose

```bash
docker-compose up -d
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hermes
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hermes
  template:
    metadata:
      labels:
        app: hermes
    spec:
      containers:
        - name: hermes
          image: hermes:latest
          ports:
            - containerPort: 50051
---
apiVersion: v1
kind: Service
metadata:
  name: hermes
spec:
  selector:
    app: hermes
  ports:
    - port: 50051
      targetPort: 50051
  type: LoadBalancer
```

## Environment Variables

| Variable           | Default | Description           |
| ------------------ | ------- | --------------------- |
| `HERMES_PORT`      | `50051` | Server listening port |
| `HERMES_LOG_LEVEL` | `info`  | Logging verbosity     |

## Health Checks

Use `grpc_health_probe` for container health checks:

```bash
grpc_health_probe -addr=:50051
```

## TLS Configuration

For production, enable TLS:

```go
creds := credentials.NewTLS(&tls.Config{...})
grpc.NewServer(grpc.Creds(creds))
```
