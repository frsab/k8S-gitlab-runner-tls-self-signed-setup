#!/bin/bash

NAMESPACE="ns-gr"
RELEASE_NAME="gitlab-runner-release"

echo "🔍 Vérification des pods..."
kubectl get pods -n $NAMESPACE

echo "🔍 Vérification des logs du runner..."
kubectl logs -l app=gitlab-runner -n $NAMESPACE --tail=20

echo "🔍 Test de connectivité GitLab..."
kubectl exec -it $(kubectl get pod -l app=gitlab-runner -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}') -n $NAMESPACE -- sh -c "nslookup gitlab.optiplex3060 && ping -c 4 gitlab.optiplex3060"

echo "🔍 Vérification de l’enregistrement du Runner..."
kubectl logs -l app=gitlab-runner -n $NAMESPACE | grep "Runner registered successfully"

echo "🔍 Test Helm..."
helm test $RELEASE_NAME -n $NAMESPACE
