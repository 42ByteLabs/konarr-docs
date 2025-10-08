# Kubernetes Deployment

This guide covers deploying Konarr server and agents on Kubernetes clusters, including configuration, security considerations, and operational best practices.

## Overview

Konarr can be deployed on Kubernetes using standard manifests or Helm charts. The deployment typically includes:

- **Konarr Server**: Web interface, API, and database
- **Konarr Agents**: Container monitoring and SBOM generation (optional)
- **Supporting Resources**: ConfigMaps, Secrets, Services, and storage

## Prerequisites

- Kubernetes cluster (v1.20+)
- `kubectl` configured to access your cluster
- Persistent storage support (for database persistence)
- LoadBalancer or Ingress controller (for external access)

## Quick Start

### Minimal Deployment

```yaml
# konarr-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: konarr
---
# konarr-server.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: konarr-server
  namespace: konarr
  labels:
    app: konarr-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: konarr-server
  template:
    metadata:
      labels:
        app: konarr-server
    spec:
      containers:
      - name: konarr-server
        image: ghcr.io/42bytelabs/konarr:latest
        ports:
        - containerPort: 9000
        env:
        - name: KONARR_DATA_PATH
          value: "/data"
        volumeMounts:
        - name: data
          mountPath: /data
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: konarr-server
  namespace: konarr
spec:
  selector:
    app: konarr-server
  ports:
  - port: 9000
    targetPort: 9000
  type: ClusterIP
```

Deploy the minimal setup:

```bash
kubectl apply -f konarr-namespace.yaml
kubectl apply -f konarr-server.yaml
```

## Troubleshooting

### Common Issues

1. **Agent Permission Issues**:

```bash
# Check agent logs
kubectl logs -n konarr -l app=konarr-agent

# Verify RBAC permissions
kubectl auth can-i get pods --as=system:serviceaccount:konarr:konarr-agent
```

1. **Storage Issues**:

```bash
# Check PVC status
kubectl get pvc -n konarr

# Check storage class
kubectl get storageclass
```

1. **Network Connectivity**:

```bash
# Test internal service connectivity
kubectl exec -n konarr deployment/konarr-agent -- curl http://konarr-server:9000/api/health

# Check ingress status
kubectl get ingress -n konarr
```

### Debug Commands

```bash
# Get all Konarr resources
kubectl get all -n konarr

# Check events
kubectl get events -n konarr --sort-by='.lastTimestamp'

# Debug pod issues
kubectl describe pod -n konarr -l app=konarr-server

# Check logs
kubectl logs -n konarr deployment/konarr-server --follow
```

## Deployment Scripts

### Complete Deployment Script

```bash
#!/bin/bash
# deploy-konarr.sh

set -e

NAMESPACE="konarr"
DOMAIN="konarr.example.com"

echo "Creating namespace..."
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "Generating secrets..."
AGENT_TOKEN=$(openssl rand -base64 32)
SERVER_SECRET=$(openssl rand -base64 32)

kubectl create secret generic konarr-secrets \
  --namespace=${NAMESPACE} \
  --from-literal=agent-token=${AGENT_TOKEN} \
  --from-literal=server-secret=${SERVER_SECRET} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Konarr server..."
envsubst < konarr-server.yaml | kubectl apply -f -

echo "Deploying Konarr agents..."
kubectl apply -f konarr-agent-daemonset.yaml

echo "Configuring ingress..."
envsubst < konarr-ingress.yaml | kubectl apply -f -

echo "Waiting for deployment..."
kubectl wait --for=condition=available --timeout=300s deployment/konarr-server -n ${NAMESPACE}

echo "Konarr deployed successfully!"
echo "Access at: https://${DOMAIN}"
echo "Agent token: ${AGENT_TOKEN}"
```

## Migration from Docker

### Data Migration

```bash
# Copy data from Docker volume to Kubernetes PV
kubectl cp /var/lib/docker/volumes/konarr_data/_data/konarr.db \
  konarr/konarr-server-pod:/data/konarr.db
```

## Best Practices

### Resource Management

- Use resource requests and limits
- Configure appropriate storage classes
- Implement monitoring and alerting
- Use horizontal pod autoscaling for high-traffic deployments

### Security

- Run as non-root user
- Use read-only root filesystems where possible
- Implement network policies
- Regular security updates and scanning

### Operations

- Implement proper backup strategies
- Monitor resource usage and performance
- Use GitOps for configuration management
- Regular testing of disaster recovery procedures

## Additional Resources

- [Server Configuration](02-server.md) - Basic server setup
- [Agent Configuration](02-agent.md) - Agent deployment options
- [Security Guide](06-security.md) - Security best practices
- [Troubleshooting](07-troubleshooting.md) - Common issues and solutions
