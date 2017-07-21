Cascade in Docker
=================

This provides nearly everything required to run
[Hannon Hill](https://www.hannonhill.com/)'s Cascade CMS inside of Docker.

The Docker image we build isn't specific to any database, environment, or
publishing target. To make it specific, you'll either need to modify these
scripts, run with a shared volume to inject some configuration, or use the
docker config tool provided by Docker starting in version 17.06 (recommended).

## Build

This image is built from the
[Oracle Java](https://store.docker.com/images/oracle-serverjre-8) image that
requires registration in the Docker Store to build. After registering,
be sure that you're logged in to the docker hub on your image build machine.

Before building the image, you should edit `docker-compose.yml` to set the
desired image name on line 28 if you don't want it named `cascade:v8.4.1`.

If you're not located in the eastern time zone, you should edit `Dockerfile`
to set the correct timezone.

Unzip the cascade [download](https://www.hannonhill.com/downloads/cascade/) into
the `cascade/` folder in the root of this directory, then run
`docker-compose build` (or `docker build -t image_name .`).

## Running

A swarm stack is defined in the `docker-compose.yml` file. Be sure that Before
deploying the stack you've set the image name and created the database password
secret. Deployment should be handled using
[`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack/).

If you're using this method you'll need to specific database connection
information in a configuration file (the password should go in a secret).

### Database

This setup expects an external database server, but you can run one in Docker
if you'd like. We run our MySQL Database server outside of Docker because it
makes data persistence easier to handle (for now).

### What's happening?

Before starting Cascade/Tomcat, a script inside the container will copy
settings in the configuration file (specified by the `CONFIG_FILE` environment
variable) and the all of the secrets in `/run/secrets` into the
`catalina.properties` file that Tomcat reads.

#### Configuration File

The configuration file can be built into your image or provided by Docker using
[docker configs](https://docs.docker.com/engine/swarm/configs/). The above
example uses docker configs to load the config file at
`config/production.properties`.

#### Database Credential

In a swarm cluster, the database credential is provided using
[docker secrets](https://docs.docker.com/engine/swarm/secrets/). The secret
needs to be setup before running the example. Make sure that the secret doesn't
end with a newline.

The secret inside the container will end up in `/run/secrets/db.password`
(db.password is the name of the Java parameter that will contain the secret).

## Known Issues

The example deployment here uses a file storage system outside of Docker.
Replacing the volume with something in docker shouldn't be too difficult if it's
something you need.

### Licensing

Docker will let you exceed your license count since we're re-using the same
hostname in every container. Be sure that your replica count doesn't exceed what
you're licensed to use.

### Load Balancing

Cascade requires persistent session data, meaning you can't load balance
multiple instances without a load balancer that that supports sticky sessions.
The swarm load balancer doesn't handle persistence, but there are others that
can (e.g. [traefik](https://traefik.io/)).

### Non-Swarm

The example setup expects some conventions that are used in Swarm mode. If you
want to use docker stand alone or in another system you'll probably need to
modify some of the configuration.

## Moving to Production

We run our dev, test, and production instances of Cascade in docker, including
the servers that serve published content. We define webservers in the same
docker-compose file so that they're deployed and managed together.
