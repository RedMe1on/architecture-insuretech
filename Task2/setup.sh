#!/bin/bash
# =============================================
# InsureTech - Kubernetes Minikube Setup Script
# =============================================

# echo "============================================="
# echo "1. Starting Minikube cluster..."
# echo "============================================="
# minikube start

# echo ""
# echo "============================================="
# echo "2. Enabling metrics-server addon..."
# echo "============================================="
# minikube addons enable metrics-server

echo ""
echo "============================================="
echo "3. Creating Deployment..."
echo "============================================="
kubectl apply -f deployment.yaml

echo ""
echo "============================================="
echo "4. Creating Service..."
echo "============================================="
kubectl apply -f service.yaml

echo ""
echo "============================================="
echo "5. Creating HPA (Horizontal Pod Autoscaler)..."
echo "============================================="
kubectl apply -f hpa.yaml

echo ""
echo "============================================="
echo "6. Checking HPA status..."
echo "============================================="
kubectl get hpa

echo ""
echo "============================================="
echo "7. Getting service URL..."
echo "============================================="
minikube service test-app-service --url

echo ""
echo "============================================="
echo "8. Opening Kubernetes Dashboard..."
echo "============================================="
echo "Run this command in another terminal:"
echo "minikube dashboard"
echo ""
echo "============================================="
echo "9. Starting Locust for load testing..."
echo "============================================="
echo "Run this command in another terminal:"
echo "locust -f locustfile.py"
echo "Then open http://localhost:8089 in browser"
echo ""
echo "============================================="
echo "Setup complete!"
echo "============================================="