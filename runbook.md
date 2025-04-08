# Kubernetes Development Environment Setup Guide

## Kind vs Minikube: Why Choose Kind?

Kind (Kubernetes in Docker) offers several advantages over Minikube for local Kubernetes development:

1. **Multi-node Clusters**: Kind can easily create multi-node clusters, making it ideal for testing distributed applications and features like pod scheduling across nodes.

2. **Docker-based**: Kind runs Kubernetes nodes as Docker containers, which means:
   - Faster startup times
   - Lower resource consumption
   - Better integration with Docker tooling
   - No need for a VM (unlike Minikube)

3. **Production-like Environment**: Kind clusters more closely resemble production environments, as they use the same container runtime (containerd) and networking stack.

4. **CI/CD Friendly**: Kind is particularly well-suited for CI/CD pipelines due to its lightweight nature and quick startup times.

5. **Better Networking**: Kind provides more realistic networking scenarios, making it easier to test service discovery and inter-pod communication.

## Setting Up a 3-Node Kind Cluster

### Prerequisites

1. Install Docker:
   ```bash
   # For macOS (using Homebrew)
   brew install docker
   
   # For Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install docker.io
   ```

2. Install kubectl:
   ```bash
   # For macOS (using Homebrew)
   brew install kubectl
   
   # For Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install -y kubectl
   ```

3. Install Kind:
   ```bash
   # For macOS (using Homebrew)
   brew install kind
   
   # For Ubuntu/Debian
   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
   chmod +x ./kind
   sudo mv ./kind /usr/local/bin/kind
   ```

### Creating a 3-Node Cluster

1. Create a Kind configuration file (`kind-config.yaml`):
   ```yaml
   kind: Cluster
   apiVersion: kind.x-k8s.io/v1alpha4
   nodes:
   - role: control-plane
   - role: worker
   - role: worker
   ```

2. Create the cluster:
   ```bash
   kind create cluster --config kind-config.yaml --name flask-cluster
   ```

3. Verify the cluster:
   ```bash
   kubectl get nodes
   ```

### Creating the Flask App Namespace

1. Create the namespace:
   ```bash
   kubectl create namespace flask-app
   ```

2. Verify the namespace:
   ```bash
   kubectl get namespaces
   ```

3. Set the namespace as default for kubectl:
   ```bash
   kubectl config set-context --current --namespace=flask-app
   ```

### Setting Up the Flask Application

1. Create a new directory and initialize the project:
   ```bash
   mkdir flask-hello
   cd flask-hello
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install required packages:
   ```bash
   pip install flask pytest pytest-cov
   ```

3. Create the basic application with a basic test file (`tests/test_app.py`) and a requirements file (`requirements.txt`) as below:
   ```
    Flask==3.0.2
    python-dateutil==2.8.2
    pytz==2024.1
    pytest==8.1.1
    pytest-flask==1.3.0 
   ```
   A sample code is present here `git@github.com:grvsoni/flask-hello.git` [private repo].

4. Test build and test the application on local:
   
   ## Setup
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

   ## Running the Application
   ```bash
   export FLASK_APP=app
   export FLASK_ENV=development
   flask run
   ```

   ## Running Tests
   ```bash
   pytest
   ```

### Pushing to GitHub

1. Initialize Git repository :
   ```bash
   git init
   ```

2. Create a .gitignore file:
   ```bash
   echo "venv/
   __pycache__/
   *.pyc
   .pytest_cache/
   .coverage
   " > .gitignore
   ```

3. Add and commit the files:
   ```bash
   git add .
   git commit -m "Initial commit: Basic Flask application setup"
   ```

4. Add the remote repository and push:
   ```bash
   git remote add origin git@github.com:grvsoni/flask-hello.git
   git branch -M main
   git push -u origin main
   ```

### Building and Publishing Docker Image

1. Create a Dockerfile in the project root:
   ```dockerfile
    # Use Python 3.11 slim image as base
    FROM python:3.11-slim

    # Set working directory
    WORKDIR /app

    # Set environment variables
    ENV PYTHONDONTWRITEBYTECODE=1 \
        PYTHONUNBUFFERED=1 \
        FLASK_APP=app.py \
        FLASK_ENV=production \
        PIP_NO_CACHE_DIR=1 \
        PIP_DISABLE_PIP_VERSION_CHECK=1

    # Install system dependencies and cleanup in one layer
    RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean

    # Create a non-root user
    RUN useradd -m myuser

    # Copy requirements first to leverage Docker cache
    COPY requirements.txt .

    # Install Python dependencies
    RUN pip install --no-cache-dir -r requirements.txt \
        && pip install --no-cache-dir pytest-cov coverage

    # Copy the application with proper permissions
    COPY --chown=myuser:myuser . .

    # Run tests (commented out temporarily)
    # RUN python -m pytest

    # Switch to non-root user
    USER myuser

    # Expose the port the app runs on
    EXPOSE 3000

    # Health check
    HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
        CMD curl -f http://localhost:3000/ || exit 1

    # Command to run the application
    CMD ["flask", "run", "--host=0.0.0.0", "--port=3000"] 
   ```

2. Create a docker-push.sh script:
   ```bash    
    #!/bin/bash

    # Read the version from VERSION file and trim whitespace
    VERSION=$(cat VERSION)
    IMAGE_NAME="grvsoni/flask-counter"

    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

    # Build the versioned image
    echo "Building image ${IMAGE_NAME}:v${VERSION}..."
    docker build -t "${IMAGE_NAME}:v${VERSION}" .
    if [ $? -ne 0 ]; then
        echo "Build failed!"
        exit 1
    fi

    # Tag as latest
    echo "Tagging as latest..."
    docker tag "${IMAGE_NAME}:v${VERSION}" "${IMAGE_NAME}:latest"

    # Push both tags
    echo "Pushing version ${VERSION}..."
    docker push "${IMAGE_NAME}:v${VERSION}"
    echo "Pushing latest tag..."
    docker push "${IMAGE_NAME}:latest"

    echo "Successfully pushed ${IMAGE_NAME}:v${VERSION} and ${IMAGE_NAME}:latest"  
   ```

3. Make the script executable:
   ```bash
   chmod +x docker-push.sh
   ```

4. Build and push the image:
   ```bash
   ./docker-push.sh
   ```

5. Verify the image on Docker Hub:
   - Visit https://hub.docker.com/
   - Log in to your account
   - Check your repository for the pushed images

### Deploying to Kubernetes

1. Create a deployment YAML file (`k8s/deployment.yaml`):
   ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: flask-counter
    namespace: flask-app
    labels:
        app: flask-counter
    spec:
    replicas: 3
    selector:
        matchLabels:
        app: flask-counter
    template:
        metadata:
        labels:
            app: flask-counter
        spec:
        containers:
        - name: flask-counter
            image: grvsoni/flask-counter:latest
            ports:
            - containerPort: 3000
            name: http
            env:
            - name: FLASK_ENV
            valueFrom:
                configMapKeyRef:
                name: flask-counter-config
                key: FLASK_ENV
            resources:
            requests:
                cpu: "100m"
                memory: "128Mi"
            limits:
                cpu: "500m"
                memory: "256Mi"
            readinessProbe:
            httpGet:
                path: /
                port: 3000
            initialDelaySeconds: 5
            periodSeconds: 10
            livenessProbe:
            httpGet:
                path: /
                port: 3000
            initialDelaySeconds: 15
            periodSeconds: 20 
   ```

2. Create a service YAML file (`k8s/service.yaml`):
   ```yaml
    apiVersion: v1
    kind: Service
    metadata:
    name: flask-counter
    namespace: flask-app
    labels:
        app: flask-counter
    spec:
    type: LoadBalancer
    ports:
        - port: 80
        targetPort: 3000
        protocol: TCP
        name: http
    selector:
        app: flask-counter 
   ```

3. Apply the Kubernetes manifests:
   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   ```

4. Verify the deployment:
   ```bash
   kubectl get pods -n flask-app
   kubectl get svc -n flask-app
   ```

### Accessing the Application

1. Port forward the service to your local machine:
   ```bash
   # Port forward the service to localhost:3000
   kubectl port-forward svc/flask-counter -n flask-app 3000:80
   ```

2. Access the application:
   - Open your web browser
   - Navigate to `http://localhost:3000`
   - You should see the Flask application with:
     - A counter that increments with each page refresh
     - The current UTC time

3. To verify the application is working correctly:
   - Refresh the page multiple times to see the counter increment
   - Check that the UTC time updates correctly
   - The page should load quickly and consistently

4. To stop port forwarding:
   - Press `Ctrl+C` in the terminal where port-forward is running
   - Or use the following command to find and kill the process:
     ```bash
     pkill -f "kubectl port-forward"
     ```

### Troubleshooting Port Forwarding

1. If port 3000 is already in use:
   ```bash
   # Use a different port (e.g., 3001)
   kubectl port-forward svc/flask-counter -n flask-app 3001:80
   ```

2. If the connection is refused:
   - Verify the pods are running:
     ```bash
     kubectl get pods -n flask-app
     ```
   - Check pod logs:
     ```bash
     kubectl logs -n flask-app deployment/flask-counter
     ```
   - Verify the service is properly configured:
     ```bash
     kubectl describe svc flask-counter -n flask-app
     ```

3. If the application is not accessible:
   - Check if the port-forward process is running:
     ```bash
     ps aux | grep "kubectl port-forward"
     ```
   - Verify the service type and ports:
     ```bash
     kubectl get svc flask-counter -n flask-app -o yaml
     ```

## Setting Up Docker Hub

1. Create a Docker Hub Account and Log in to your new account

2. Create a New Repository:
   - After logging in, click "Create Repository" button
   - Fill in the repository details:
     - Name: `flask-counter`
     - Visibility: Public (for free account)
     - Description: "A Flask application that displays a counter and UTC time"
   - Click "Create"

3. Set Up Docker Credentials:
   - Create a `.docker/config.json` file in your home directory:
     ```bash
     mkdir -p ~/.docker
     touch ~/.docker/config.json
     ```
   - Log in to Docker Hub from your terminal:
     ```bash
     docker login
     ```
   - Enter your Docker Hub username and password when prompted

## So far in this guide, we have successfully:

1. Set up a local Kubernetes development environment using Kind, creating a 3-node cluster
2. Created a Flask application with counter and UTC time display functionality
3. Containerized the application using Docker with best practices
4. Published the Docker image to Docker Hub
5. Deployed the application to Kubernetes with:
   - Proper resource limits
   - Health checks
   - Load balancing
   - Multiple replicas for high availability
6. Set up port forwarding to access the application locally

The setup provides a production-like environment for development and testing, with all the necessary components for a scalable web application. The application can be accessed locally through port forwarding, and the deployment is configured with proper resource management and health monitoring.

This setup serves as a foundation that can be extended with CI/CD pipeline integration in Harness.io.

