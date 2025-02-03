
# Kubernetes Deployment for a Web App

A web application designed to run in Docker containers and deployed on Kubernetes. This project uses Docker, and Kubernetes for containerization and orchestration.

## Prerequisites

Before you begin, ensure you have the following tools installed:

- Docker: [Install Docker](https://docs.docker.com/get-docker/)
- Kubernetes: [Install Kubernetes](https://kubernetes.io/docs/setup/)
- Minikube: if you want to run Kubernetes locally.
- Helm: [Install Helm](https://helm.sh/docs/intro/install/)

### Step 1: Build the Docker Image

From the project root (where the `Dockerfile` is located), run the following command to build the Docker image:

```bash
docker build -t k8s-web-app .
```

### Step 2: Run the Docker Container

Once the image is built, run the container:

```bash
docker run -p 3008:3008 k8s-web-app
```

This will run the application on port `8080` locally. You can access the app by navigating to `http://localhost:8080` in your browser.

### Step 3: Tag and Push the Docker Image

After building the Docker image, you need to tag it for your Docker Hub repository. Replace your_image_name with the image you’ve built and tag with the version tag.

```bash
docker tag your_image_name:tag username/your_image_name:tag
```` 
**`your_image_name`**:tag is the name and tag of your locally built image.

**`username/your_image_name`** :tag is the target image name on Docker Hub, where username is your Docker Hub username.

Now that the image is tagged, you can push it to Docker Hub by running the following command:

```` bash
docker push username/your_image_name:tag
````
This will upload your image to Docker Hub (or any other registry you are using) under your username/repository name.

## Deploying to Kubernetes

You can deploy the application to your Kubernetes cluster using `kubectl`.

### Using kubectl

#### Step 1: Apply Kubernetes Resources

The `k8s` directory contains Kubernetes configuration files. To deploy the application, apply the Kubernetes manifests for deployment and service.

```bash
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
```

#### Step 2: Check the Status of the Deployment

Verify that your pods and services are running by using:

```bash
kubectl get pods
kubectl get svc
```

Once the pods are running, you can proceed to access the application.

## Accessing the Application

### If Using Minikube

If you're using **Minikube** or a local Kubernetes cluster, you can access the application through the following command:

```bash
minikube service k8s-web-app --url
```

This will return the URL where your app is accessible.

### If Using kubectl Port Forwarding

If you're using **Kind** or a cloud Kubernetes cluster, you may need to port-forward the service to access it locally:

```bash
kubectl port-forward svc/k8s-web-app 8080:80
```

This will make the app accessible on `http://localhost:8080`.

## Kubernetes Configurations

### Deployment YAML

The `k8s/deployment.yml` file defines how to deploy your application on Kubernetes. Here's a breakdown of its key components:

```yaml
apiVersion: apps/v1  # Specifies the API version for the Deployment resource
kind: Deployment  # Specifies the kind of resource to create, in this case, a Deployment
metadata:  # Metadata section for the Deployment
  name: k8s-web-application  # Name of the deployment, used to reference the deployment
  namespace: default  # Specifies the namespace where the deployment will reside (default namespace is used here)
spec:  # Specification of the deployment configuration
  replicas: 3  # Number of pod replicas to create. Here, three replicas ensure high availability
  selector:  # Selector to match the pods based on labels
    matchLabels:  # Define the labels to match for the pods managed by this deployment
      app: k8s-web-application  # This label matches the pods with app=k8s-web-application
  template:  # Template for the pod that will be created
    metadata:  # Metadata for the pod template
      labels:  # Labels applied to the pods created by this deployment
        app: k8s-web-application  # Ensure the pods are labeled with the same app name
    spec:  # Specification of the pod's configuration
      containers:  # List of containers to run inside the pod
      - name: k8s-web-application  # Name of the container
        image: <user_name>/k8s-web-application:latest  # Docker image used for the container (latest tag)
        ports:  # Ports to expose inside the container
        - containerPort: 3008  # The application inside the container listens on port 3008
        resources:  # Define resource requests and limits for the container
          requests:
            cpu: "250m"  # The container requests 250 milliCPU units (0.25 of a CPU core)
            memory: "64Mi"  # The container requests 64 MiB of memory
          limits:
            cpu: "500m"  # The maximum CPU limit is 500 milliCPU units (0.5 of a CPU core)
            memory: "128Mi"  # The maximum memory limit is 128 MiB
```

**Explanation of `deployment.yml`**:
- **`apiVersion`**: Specifies the version of the Kubernetes API to use. `apps/v1` is the current version for deploying applications.
- **`kind`**: Specifies that the resource is a `Deployment`. This ensures that Kubernetes can manage and scale the application.
- **`metadata`**: The `name` identifies the deployment, and `namespace` specifies where it will be deployed (default is fine unless you want to use a different namespace).
- **`spec`**:
  - **`replicas`**: Defines the number of pod replicas to run for scaling and availability. Here, it’s set to `3` for high availability.
  - **`selector`**: The `matchLabels` section ensures that the deployment manages pods with the `app: k8s-web-application` label.
  - **`template`**: This is the pod template. It defines the pods that the deployment will create and manage:
    - **`containers`**: This specifies the container to run in the pod, the Docker image, the port to expose, and the resources requested/limited.
    - **`resources`**: Specifies the amount of CPU and memory the container requests and the limits set for it to ensure optimal performance and avoid resource hogging.

---

### Service YAML

The `k8s/service.yml` file defines how to expose your application within the Kubernetes cluster. Here's an explanation:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: k8s-web-application
spec:
  selector:
    app: k8s-web-application  # Ensures the service routes traffic to the correct pods
  ports:
    - protocol: TCP
      port: 80        # The port the service will expose internally in the cluster
      targetPort: 3008  # The port the container listens to inside the pod
  type: LoadBalancer  # Expose the service externally if supported (use NodePort for local clusters)
```

**Explanation of `service.yml`**:
- **`apiVersion`**: The version of the API for the service (v1 is stable for services).
- **`kind`**: The type of resource is a `Service`.
- **`metadata`**: Includes the name of the service (`k8s-web-application`).
- **`spec`**:
  - **`selector`**: Ensures the service forwards traffic to the pods labeled with `app: k8s-web-application`.
  - **`ports`**: Defines the internal port (`80`) that the service will listen on and forward traffic to the container port (`3008`).
  - **`type`**: The type of service. `LoadBalancer` exposes the service externally. If using a local Kubernetes cluster, you may want to use `NodePort` instead.