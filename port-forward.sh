#!/bin/bash

# Configuration
NAMESPACE="flask-app"
SERVICE_NAME="flask-counter"
LOCAL_PORT="8080"
REMOTE_PORT="80"

echo "Starting persistent port forwarding..."
echo "Local port: ${LOCAL_PORT}"
echo "Remote port: ${REMOTE_PORT}"
echo "Service: ${SERVICE_NAME}"
echo "Namespace: ${NAMESPACE}"
echo "Press Ctrl+C to stop"

while true; do
    kubectl port-forward svc/${SERVICE_NAME} ${LOCAL_PORT}:${REMOTE_PORT} -n ${NAMESPACE}
    echo "Port forwarding interrupted. Reconnecting in 2 seconds..."
    sleep 2
done 