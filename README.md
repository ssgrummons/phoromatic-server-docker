# Phoromatic Server - Docker Container
 
The [Phoronix Test Suite](https://github.com/phoronix-test-suite/phoronix-test-suite) is a comprehensive testing and benchmarking platform available for Linux, Solaris, macOS, Windows, and BSD operating systems.  I have been running it on [RedHat Openshift](https://www.redhat.com/en/technologies/cloud-computing/openshift).

## Running on RedHat OpenShift

Getting this application containerized required some significant experimentation and some guidance from the developer.  I started with [this example](https://github.com/mgasiorowski/phoromatic-server-docker); however, I have made some adjustments from there due to some challenges I had with the way Openshift differs from Docker.

### Random User ID
OpenShift does not by default run as the root user; rather it assigns a [random UID as the container's user ID](https://cookbook.openshift.org/users-and-role-based-access-control/why-do-my-applications-run-as-a-random-user-id.html).  So I needed to ensure that the directories I used were accessible by a random user.
```
RUN chmod -R ugo+rw ${PHORONIX_CACHE} &&\
    chmod -R ugo+rwx ${INSTALL_DIR} &&\
    chmod -R ugo+rw /var/lib &&\
    chmod -R ugo+rw /etc 
```  

### Ensuring the Application Runs as a Service
In order for the container to stay running and not trigger a `Press [ENTER] to kill server...` prompt, the directories need to be set up with the [correct permissions](https://github.com/phoronix-test-suite/phoronix-test-suite/issues/615).  If the user has write access to `/var/lib` and `/etc`, then when running the command `./phoronix-test-suite start-phoromatic-server` it will not prompt to kill the server and continue running.  

## Running Locally

I have run this in both Docker Desktop and Podman.  With the Docker Desktop's [licensing changes](https://www.docker.com/blog/updating-product-subscriptions/), I installed [Podman on WSL2](https://www.redhat.com/sysadmin/podman-windows-wsl2) and am now doing my local tests using Podman.  Included are both instructions. 

```
# Navigate to this directory and build the image
docker build -t phoromatic .

# Create a volume
docker volume create phoromatic

# Run locally using the -u argument to specify a random user
# Here I randomly assigned a user
docker run --name phoromatic -d -p 8089:8089 -p 8088:8088 -u 920202 -v phoromatic:/var/lib/phoronix-test-suite/phoromatic phoromatic:latest
```

For Podman I ran the following in Rootless Podman:
```
# Navigate to this directory and build the image
podman build -t phoromatic .

# Create a volume
podman volume create phoromatic

# Run locally and assign a random user
podman run -i -t --name phoromatic -u=12345 -d -p 8089:8089 -p 8088:8088 -v phoromatic:/var/lib/phoronix-test-suite/phoromatic phoromatic:latest

#Check the logs
podman logs phoromatic
```

