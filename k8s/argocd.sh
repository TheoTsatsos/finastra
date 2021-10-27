#!/usr/bin/bash

kubectl config use-context aks-cluster1

# Create ArgoCD namespace:
kubectl create namespace argocd

#Install ArgoCD in Kubernetes
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Expose ArgoCD API Server:
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Config ArgoCD CLI with username admin and password admin:
kubectl -n argocd patch secret argocd-secret \
    -p '{"stringData": {"admin.password": "$2a$10$mivhwttXM0U5eBrZGtAG8.VSRL1l9cZNAmaSaqotIzXRBRwID1NT.",
        "admin.passwordMtime": "'$(date +%FT%T)'"
    }}'
argocd login localhost:10443 --username admin --password admin --insecure

# Expose ArgoCD UI:
kubectl port-forward svc/argocd-server -n argocd 10443:443 2>&1 > /dev/null &

