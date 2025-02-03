FROM debian

ARG DEBIAN_FRONTEND=noninteractive
ARG RUNNER_VERSION=2.322.0
ARG RUNNER_USER=github_runner

ARG RUNNER_TARBALL=actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
ARG RUNNER_HOME=/home/${RUNNER_USER}

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        liblttng-ust1 \
        libicu72 \
        ssh \
        jq

RUN curl -o /tmp/${RUNNER_TARBALL} \
    -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_TARBALL}

RUN useradd -m ${RUNNER_USER} && \
    mkdir -p ${RUNNER_HOME}

RUN cd ${RUNNER_HOME} && tar -xzf /tmp/${RUNNER_TARBALL}
RUN cd ${RUNNER_HOME} && ./bin/installdependencies.sh

RUN chown -R ${RUNNER_USER}:${RUNNER_USER} ${RUNNER_HOME}

ADD start.sh /start.sh
ADD vm_exec /vm_exec
ENTRYPOINT [ "/start.sh" ]

USER ${RUNNER_USER}
