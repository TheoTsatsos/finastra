#!/usr/bin/bash

# Create a repo in your Github account
gh repo create --public git2k8s -y && cd git2k8s

# Add Readme.md and push to Github.
echo "From GIT to Kubernetes" > Readme.md
git add Readme.md
git commit -m "Added Readme.md" && git push --set-upstream origin master

# Create live branch and push to Github with no kubernetes resources.
git branch live
git push --set-upstream origin live

# Upload “Guestbook” deployment file and commit changes to Github:
git checkout master
curl -kSs https://raw.githubusercontent.com/kubernetes/examples/master/guestbook/all-in-one/guestbook-all-in-one.yaml -o guestbook_app.yaml
git add guestbook_app.yaml
git commit -m "Added guestbook_app.yaml"
git push --set-upstream origin master

# Deploy using ArgoCD
# After the repo is ready, we must create an ArgoCD app using its own custom kubernetes resource. Furthermore, we are going to create a new namespace to deploy on it.

# Obtain HTTPS url of the GIT repository:
HTTPS_REPO_URL=$(git remote show origin |  sed -nr 's/.+Fetch URL: git@(.+):(.+).git/https:\/\/\1\/\2.git/p')

# Create k8s namespace:
kubectl create namespace git2k8s10min

# Deploy App:
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: git2k8s
  namespace: argocd
spec:
  destination:
    namespace: git2k8s
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: $HTTPS_REPO_URL
    path: .
    targetRevision: master
EOF

# Although the app is created, it has not been “deployed”. So we have to synchronize the app manually:
argocd app sync git2k8s

# Check app status using Arcgocd CLI:
argocd app get git2k8s

# Check Kubernetes resources using kubectl:
kubectl get -n git2k8s10min svc/frontend pods

# Run the following command to forward port 18080 on your local machine to port 80 on the service.
kubectl port-forward -n git2k8s svc/frontend 18080:80

# --> Finally again, test http://localhost:18080 in your browser to view Guestbook app.



