FROM ubuntu:24.04

ENV PROJECT="vscode-tunnels"
ENV PROJECT_DIR="/home/${PROJECT}"

VOLUME $PROJECT_DIR

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    git \
    ca-certificates \
    dbus-user-session \
    tzdata \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ARG TARGETPLATFORM
RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  CLI_OS_PKG="cli-alpine-x64"   ;; \
         "linux/arm64")  CLI_OS_PKG="cli-alpine-arm64" ;; \
         *)              CLI_OS_PKG="not-supported"    ;; \
    esac \
    && wget -q "https://code.visualstudio.com/sha/download?build=stable&os="${CLI_OS_PKG} -O /tmp/vscode_cli.tar.gz \
    && tar -xzf /tmp/vscode_cli.tar.gz -C /usr/bin \
    && chown root:root /usr/bin/code \
    && chmod +x /usr/bin/code \
    && rm /tmp/vscode_cli.tar.gz

RUN adduser -D $PROJECT \
    && echo "$PROJECT ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$PROJECT \
    && chmod 0440 /etc/sudoers.d/$PROJECT \
    && chown -R $PROJECT:$PROJECT $PROJECT_DIR

USER $PROJECT
WORKDIR $PROJECT_DIR

ENTRYPOINT ["code", "tunnel", "service", "install", "--accept-server-license-terms", "--disable-telemetry"]
