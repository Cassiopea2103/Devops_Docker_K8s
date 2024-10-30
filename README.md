

<h4  align="center"><font  color="#BD6C37">

Ecole Polytechnique de Thiès
<br>
Département Génie Informatique et Télécoms
</h4>

<h1  align="center"><font  color="#3581B8">
K8S lab
</h1>
<img src="https://github.com/user-attachments/assets/202dd906-7e7f-4de5-acf9-0b9bf88abe6f" />
<div align="left">
<small align="left">By </small><i>Serigne Saliou WADE</i>

<span align="right"><small>Tutor  : </small> Ibrahima MBENGUE</span>
</div>


---

## I. Containerization with Docker / docker-compose 
<small><i> Prior to the K8s lab , we had to redo the Docker lab as the VMs on which we set up formerly our work environment are lost . </i></small>

#### 1. Express backend app 
We create a simple node/express backend with basic CRUD operations on users with a Posgres database . 

`Basic folder structure for our project`  
![1 folder_structure](https://github.com/user-attachments/assets/cdf76d7b-04e8-4839-978b-0c1ad8330b0b)


`db.js` file content :   
![2 db js](https://github.com/user-attachments/assets/64befbc0-4203-46a4-ac45-0baca1ac75f7)

  
`index.js`  
![3 index js](https://github.com/user-attachments/assets/a06c11ea-04f6-4f98-970d-6d2cd5c92d95)


`.env file contains our local database confiurations`   
![4 env](https://github.com/user-attachments/assets/2f55f818-88f9-43b6-a633-4f52ac6ed0bc)


#### 2. Building the app with Docker and running it locally 
For that , we have the `Dockerfile` , with the following content :

![5 Dokerfile](https://github.com/user-attachments/assets/79799a9e-7165-4dd9-a7c0-034a796f48c1)


We can pull the postgres image from docker hub  
```docker 
docker pull posgres
```

After which we have to create a network for our containers to communicate : 
```docker
docker network create backend_network 
``` 

We then run the database image seperately to have our db container ( run the database within the network ) : 

```docker
docker run --name postgres_db --network=backend_network -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=Saliou2103wade -e POSTGRES_DB=company -p 5432:5432 -d postgres
```

With our database container running , we can now create our backend server image and run it on a container : 

* create docker image for the backend
```docker 
docker build -t backend_app . 
```  

* run the image on the same network as the database :
```docker 
docker run --name backend_container --network backend_network -p 3000:3000 backend_app 
```      
![7 docker_build_docker_images](https://github.com/user-attachments/assets/c6e83dca-319e-413b-a5be-637c285dbcd0)

![8 app_container_started_connected_to_db](https://github.com/user-attachments/assets/881f86f4-aca5-49a9-8200-f97855543af6)

---
#### Pushing the app to Docker hub 
1. create a tag for the app  
```docker 
docker build - t cassiopea21/backend_app . 
```

2. Login to docker 
```docker 
docker login
```  

3. push the image to docker hub 
```docker 
docker push cassiopea21/backend_app 
```
![9 dockerhub_images](https://github.com/user-attachments/assets/ec4c4a51-bb29-42e8-8ee5-ee7e124f55bd)


#### Docker compose configuration 
![docker-compose](https://github.com/user-attachments/assets/fc6e0a30-96b0-4f99-8a02-c969fb010633)

    
 

##### Services

1.  **postgres_db**:
    
    -   **`image: postgres:latest`**: Uses the latest official PostgreSQL image from Docker Hub.
    -   **`container_name: postgres_db`**: Sets the container name to `postgres_db` for easier identification and networking.
    -   **`env_file`**: Loads environment variables (like `POSTGRES_USER`, `POSTGRES_PASSWORD`, etc.) from a `.env` file.
    -   **`ports: "5432:5432"`**: Maps the host machine’s port `5432` to the container’s PostgreSQL port `5432`.
    -   **`volumes`**:
        -   **`./init.sql:/docker-entrypoint-initdb.d/init.sql`**: Mounts a SQL initialization file from the host to the container, ensuring the database structure is created when the container first starts.
    -   **`networks`**:
        -   **`backend_network`**: Connects this service to the `backend_network`, a custom bridge network for inter-service communication.
    -   **`healthcheck`**:
        -   **`test`**: Runs `pg_isready -U $POSTGRES_USER` to check if PostgreSQL is ready to accept connections.
        -   **`interval`**: Runs the health check every `10` seconds.
        -   **`timeout`**: Sets a timeout of `5` seconds for each health check.
        -   **`retries`**: Retries `5` times before marking the service as unhealthy.
2.  **backend_app**:
    
    -   **`build: .`**: Builds the backend application from the Dockerfile in the current directory.
    -   **`container_name: backend_app`**: Names the container `backend_app`.
    -   **`env_file`**: Loads environment variables from the `.env` file.
    -   **`ports: "3000:3000"`**: Maps the host’s port `3000` to the container’s application port `3000`.
    -   **`depends_on`**:
        -   **`postgres_db: condition: service_healthy`**: Ensures the `postgres_db` service must be healthy before starting `backend_app`.
    -   **`networks`**:
        -   **`backend_network`**: Connects this service to the `backend_network` for inter-service communication.

----------

##### Networks

-   **backend_network**:
    -   **`driver: bridge`**: Creates a custom bridge network, allowing controlled communication between `postgres_db` and `backend_app`



After running 
```docker 
docker-compose up 
```

![10 docker-compose-success](https://github.com/user-attachments/assets/c74458b5-1fc9-4187-8cb0-8069bb78976a)

we can then perform test on our backend applications with its exposed PORTS 

* CREATING USER
  ![12 test-create](https://github.com/user-attachments/assets/a1636905-fa57-4189-a046-e16d53e53cf3)

* GETTING USERS LIST
  ![11 test-backend-get](https://github.com/user-attachments/assets/f34f8cfe-64c5-46f0-b8bf-0d302eea52f8)

* UPDATING A USER
  ![14 test-update](https://github.com/user-attachments/assets/ddd864a0-0440-4676-9b21-a06e7c2e37bf)

* DELETING USER
  ![13 test-delete](https://github.com/user-attachments/assets/f0f4de00-8bcf-4248-b42f-8b315ff9cbc0)
  


Here is the github repo containing the project : 
[Github repository](https://github.com/Cassiopea2103/Devops_Docker_K8s/tree/master/express-postgres)



# K8s 

## README for running the app on K8S 
### All k8s configurations files are in the k8s folder of the project ) 
# Kubernetes Setup for Express and PostgreSQL Application

## Prerequisites

- Kubernetes cluster (e.g., using Minikube)
- Kubectl installed and configured

## Steps to Run the Application

1. **Start Minikube with 3 Nodes:**
   ```bash
   minikube start --nodes 3 --driver=docker
   ```   
2. **Apply K8s manifest files**
 ```bash
 kubectl apply -f k8s/database-secret.yml
  kubectl apply -f k8s/database-configmap.yml
  kubectl apply -f k8s/database-deployment.yml
  kubectl apply -f k8s/database-service.yml
  kubectl apply -f k8s/backend-secret.yml
  kubectl apply -f k8s/backend-configmap.yml
  kubectl apply -f k8s/backend-deployment.yml
  kubectl apply -f k8s/backend-service.yml
  kubectl apply -f k8s/database-network-policy.yml
  ```

3. **Verify pods**
 ```bash
kubectl get pods
```
![77 runningpods](https://github.com/user-attachments/assets/f1a3a6f4-c142-423f-a3a1-02f2f369efae)


4. **Check services**
```bash
kubectl get services
```
![78 services url](https://github.com/user-attachments/assets/98d2f0a5-94d5-4320-a20a-87f26dfa7921)


4. **Access the app**
 ```bash
 minikube service backend-service --url
```
`We can then interact with the URL provided to reach out to our backend server`
<small>_In our case , our BASE url is http://127.0.0.1:58771_</small>


5. **Test the k8s deployments**
Creating user :
![79 test](https://github.com/user-attachments/assets/5b0632f1-802c-436a-ad23-d30ec5bbc955)

  
  
  
