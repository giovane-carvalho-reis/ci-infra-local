FROM ubuntu:22.04

ARG RUNNER_VERSION=2.328.0

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    tar \
    git \
    libicu70 \
    libssl3 \
    zlib1g \
    libkrb5-3 \
    sudo \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /actions-runner

RUN curl -fL --connect-timeout 10 --max-time 120 \
    -o actions-runner.tar.gz \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf actions-runner.tar.gz \
    && test -x ./config.sh && test -x ./run.sh \
    && rm -f actions-runner.tar.gz

RUN ./bin/installdependencies.sh

RUN useradd -m -G docker runner && chown -R runner:runner /actions-runner

COPY start.sh .
RUN chmod +x start.sh

USER runner

CMD ["./start.sh"]
