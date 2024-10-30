

<h4  align="center"><font  color="#BD6C37">

Ecole Polytechnique de Thiès
<br>
Département Génie Informatique et Télécoms
</h4>

<h1  align="center"><font  color="#3581B8">
K8S lab
</h1>
![k8s](https://github.com/user-attachments/assets/94c0349d-ad03-4323-8c20-5b4cc70e6e9d)
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
IMAGE

`db.js` file content : 

`index.js`

`Dockerfile`

`.env file contains our local database confiurations` 

#### 2. Building the app with Docker and running it locally 
For that , we have the `Dockerfile` , with the following content :

IMAGE 

We can pull the postgres image from docker hub  
```docker 
docker pull posgres
```

After which we have to create a network for our containers to communicate : 
```docker
docker network create backend_network 
``` 

after which we can run the database image seperately to have our db container ( run the database within the network ) : 

```docker
docker run --name postgres_db --network=backend_network -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=Saliou2103wade -e POSTGRES_DB=company -p 5432:5432 -d postgres
```

With our database container running , we can create our backend image and run it on a container : 

* create docker image for the backend
```docker 
docker build -t backend_app . 
```  

* run the image on the same network as the database :
```docker 
docker run --name backend_container --network backend_network -p 3000:3000 backend_app 
```    

IMAGE 

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

#### Docker compose configuration 
IMAGE 
  
    
 

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
we can then perform test on our backend applications with its exposed PORTS 

* CREATING USERS 
* GETTING USERS LIST 
* UPDATING A USER 
* DELETING USER 


Here is the github repo containing the project : 
[Github repository](https://github.com/Cassiopea2103/Devops_Docker_K8s/tree/master/express-postgres)




