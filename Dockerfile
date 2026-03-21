FROM ubuntu:22.04

ARG RUNNER_VERSION=2.328.0

RUN apt-get update && apt-get install -y \
    curl \
    tar \
    git \
    sudo \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /actions-runner

RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner.tar.gz \
    && rm -f actions-runner.tar.gz

RUN useradd -m runner && chown -R runner:runner /actions-runner

COPY start.sh .
RUN chmod +x start.sh

USER runner

CMD ["./start.sh"]
