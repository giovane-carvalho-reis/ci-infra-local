FROM ubuntu:22.04

ARG RUNNER_VERSION=2.328.0


ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tar \
    git \
    libicu70 \
    libssl3 \
    zlib1g \
    libkrb5-3 \
    sudo \
    gnupg \
    gosu \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Instala OpenJDK 25 via apt-get (se disponível)
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-25-jdk || \
    (echo 'Pacote openjdk-25-jdk não encontrado nos repositórios. Verifique a disponibilidade ou use uma imagem base com Java 25.')

ENV JAVA_HOME=/usr/lib/jvm/java-25-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Adiciona o repositório oficial do Docker e instala docker.io e docker-compose-plugin
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker.io docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    npm cache clean --force && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.npm && \
    node --version && npm --version
    
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
COPY entrypoint.sh .
RUN chmod +x start.sh entrypoint.sh

# Garante permissões corretas para o diretório de trabalho do runner
RUN mkdir -p /actions-runner/_work && chown -R runner:runner /actions-runner/_work

# Não define USER runner aqui, entrypoint faz o drop de privilégio
ENTRYPOINT ["/actions-runner/entrypoint.sh"]
