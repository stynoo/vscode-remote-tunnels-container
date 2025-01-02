FROM ubuntu:24.04

ARG PROJECT="vscode-tunnels"
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV PROJECT_DIR="/home/${PROJECT}"

VOLUME $PROJECT_DIR

RUN apt-get update && apt-get install -y --no-install-recommends \
    adduser sudo \
    tzdata \
    git \
    wget curl ca-certificates \
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

RUN whereis deluser \
    && whereis useradd \
    && deluser --remove-home ubuntu || true \
    && deluser --group ubuntu || true \
    && groupadd --gid $USER_GID $PROJECT || true \
    && useradd --uid $USER_UID --gid $USER_GID -m $PROJECT -d $PROJECT_DIR \
    && chown -R $PROJECT:$PROJECT $PROJECT_DIR \
    && echo "$PROJECT ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$PROJECT \
    && chmod 0440 /etc/sudoers.d/$PROJECT

USER $PROJECT
WORKDIR $PROJECT_DIR

ENTRYPOINT ["code", "tunnel", "--accept-server-license-terms"]
