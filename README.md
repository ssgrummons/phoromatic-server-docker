# Phoromatic Server - Docker Container
 
The [Phoronix Test Suite](https://github.com/phoronix-test-suite/phoronix-test-suite) is a comprehensive testing and benchmarking platform available for Linux, Solaris, macOS, Windows, and BSD operating systems.  This Docker container is based off of work [here](https://github.com/mgasiorowski/phoromatic-server-docker); however, it is updated to be able to run on [RedHat Openshift](https://www.redhat.com/en/technologies/cloud-computing/openshift).

## Running on RedHat OpenShift

In order to get this to run on OpenShift, I needed to make two changes.

### Random User ID
OpenShift does not by default run as the root user; rather it assigns a [random UID as the container's user ID](https://cookbook.openshift.org/users-and-role-based-access-control/why-do-my-applications-run-as-a-random-user-id.html).  So I needed to ensure that the directories I used were accessible by a random user.
```
RUN chmod -R ugo+rwx ${PHORONIX_USERDIR} &&\
    chmod -R ugo+rwx ${INSTALL_DIR}
```  

### Fixing an Application bug
By setting `PTS_IS_DAEMONIZED_SERVER_PROCESS=1` the server was supposed to be able to run independently and not prompt the user to kill the server.  However, due to an [issue in the code](https://github.com/phoronix-test-suite/phoronix-test-suite/issues/615), I needed to manually update the line to properly read the environment variables I set in the Dockerfile.
```
RUN sed -i "s/PTS_IS_DAEMONIZED_SERVER_PROCESS/getenv('PTS_IS_DAEMONIZED_SERVER_PROCESS')/g" ${INSTALL_DIR}/pts-core/commands/start_phoromatic_server.php
```

## Running Locally

I have run this in both Docker Desktop and Podman.  With the Docker Desktop [licensing changes](https://www.docker.com/blog/updating-product-subscriptions/), I installed [Podman on WSL2](https://www.redhat.com/sysadmin/podman-windows-wsl2) and ran it that way.  Included are both instructions. 

```
# Navigate to this directory and build the image
docker build -t phoromatic .

# Create a volume
docker volume create phoronix-test-suite

# Run locally using the -u argument to specify a random user
# Here I randomly assigned user 90210
docker run --name phoromatic -d -p 8089:8089 -p 8088:8088 -u 920202 -v phoronix-test-suite:/.phoronix-test-suite phoromatic:latest
```

For Podman I ran the following in Rootless Podman:
```
# Navigate to this directory and build the image
podman build -t phoromatic .

# Create a volume
podman volume crate phoromatic

# Run locally and assign a random user
podman run -i -t --name phoromatic -u=12345 -d -p 8089:8089 -p 8088:8088 -v phoromatic:/.phoronix-test-suite/phoromatic phoromatic:latest

#Check the logs
podman logs phoromatic
```

## Summary
This is definitely a work in progress.  I know there is more to do to improve logging and fix some other bugs I see.  I am welcome to any feedback or ideas.  Thanks!