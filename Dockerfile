FROM alpine:latest

ARG TARGETPLATFORM=linux/amd64
ARG RUNNER_VERSION=2.319.1
ARG RUNNER_CONTAINER_HOOKS_VERSION
# Docker and Docker Compose arguments
ARG CHANNEL=stable
ARG DOCKER_VERSION=24.0.7
ARG DOCKER_COMPOSE_VERSION=v2.23.0
ARG DUMB_INIT_VERSION=1.2.5
ARG RUNNER_USER_UID=1001
ARG DOCKER_GROUP_GID=121

RUN apk update

# Add repositories

ENV DEBIAN_FRONTEND=noninteractive
RUN addgroup docker --gid $DOCKER_GROUP_GID

# required
RUN apk add curl  ca-certificates docker jq git git-lfs docker-compose dumb-init
# optional
RUN apk add ansible-core
RUN apk --no-cache add shadow 
# Download latest git-lfs version
# Runner user
RUN adduser --disabled-password --gecos "" --uid $RUNNER_USER_UID runner \
    && usermod -aG wheel,docker runner \
    && echo "%wheel   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers 

ENV HOME=/home/runner

ENV RUNNER_ASSETS_DIR=/runnertmp
RUN apk add dotnet6-sdk yaml-dev && mkdir $RUNNER_ASSETS_DIR

ENV RUNNER_TOOL_CACHE=/opt/hostedtoolcache
RUN mkdir /opt/hostedtoolcache \
    && chgrp docker /opt/hostedtoolcache \
    && chmod g+rwx /opt/hostedtoolcache

RUN cd "$RUNNER_ASSETS_DIR" \
    && curl -fLo runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v0.6.1/actions-runner-hooks-k8s-0.6.1.zip \
    && unzip ./runner-container-hooks.zip -d ./k8s \
    && rm -f runner-container-hooks.zip

# We place the scripts in `/usr/bin` so that users who extend this image can
# override them with scripts of the same name placed in `/usr/local/bin`.
COPY entrypoint-dind.sh startup.sh logger.sh wait.sh graceful-stop.sh update-status /usr/bin/
RUN chmod +x /usr/bin/entrypoint-dind.sh /usr/bin/startup.sh

# Copy the docker shim which propagates the docker MTU to underlying networks
# to replace the docker binary in the PATH.
COPY docker-shim.sh /usr/local/bin/docker

# Configure hooks folder structure.
COPY hooks /etc/arc/hooks/

VOLUME /var/lib/docker

# Add the Python "User Script Directory" to the PATH
ENV PATH="${PATH}:${HOME}/.local/bin"
ENV ImageOS=alpine320

RUN echo "PATH=${PATH}" > /etc/environment \
    && echo "ImageOS=${ImageOS}" >> /etc/environment \
    && apk add bash sudo

# No group definition, as that makes it harder to run docker.
USER runner

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["entrypoint-dind.sh"]
