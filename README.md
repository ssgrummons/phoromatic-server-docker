# Phoromatic Server - Docker Container
 
The [Phoronix Test Suite](https://github.com/phoronix-test-suite/phoronix-test-suite) is a comprehensive testing and benchmarking platform available for Linux, Solaris, macOS, Windows, and BSD operating systems.  This Docker container is based off of work [here](https://github.com/mgasiorowski/phoromatic-server-docker); however, it is updated to be able to run on [RedHat Openshift](https://www.redhat.com/en/technologies/cloud-computing/openshift).

## Running on RedHat OpenShift

In order to get this to run on OpenShift, I needed to make two changes.

### Random User ID
OpenShift does not by default run as the root user; rather it assigns a [random UID as the container's user ID](https://cookbook.openshift.org/users-and-role-based-access-control/why-do-my-applications-run-as-a-random-user-id.html).  By default, that user ID is placed in the root group.  In order to get this to work, I needed to ensure that all the phoronix components were a member of the root group.  I also created a user and user group in the case this was run without specifying a user in Docker Desktop.  

### Phoromatic Kept Exiting
For some odd reason, I experienced the same issue as [this guy](https://stackoverflow.com/questions/55652074/docker-container-registers-enter-key-on-terminal-continuously).  Essentially, after the container started and the command to start the Phoromatic server was ran, the processes were killed and exited like someone pressed `Enter` at the the `Press [ENTER] to stop the server` prompt.

Right now, I will admit that this is not optimized for Docker yet, as it is called as a separate process on a server and Docker containers are intended to run only one process.  However, to get this to work without do a major rewrite of the code, I needed to trick the container into not stopping by running `tail -f /dev/null` after starting the Phoromatic process (a hack, I know).

## Running Locally

Navigate to this directory 

```
# Navigate to this directory and build the image
docker build -t phoromatic .

# Create a volume
docker volume create phoronix-test-suite

# Run locally using the -u argument to specify a random user
# Here I randomly assigned user 90210
docker run -i -t --name phoromatic -d -p 8089:8089 -p 8088:8088 -v phoromatic:/home/phoronix/.phoronix-test-suite/phoromatic phoromatic:latest
```

## Summary
This is definitely a work in progress.  I am welcome to any feedback or ideas.  Thanks!