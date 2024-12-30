FROM alpine:latest

ENV PROJECT="vscode-tunnels"

RUN apk --no-cache add git

ARG TARGETPLATFORM
RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  CLI_OS_PKG="cli-alpine-x64"   ;; \
         "linux/arm64")  CLI_OS_PKG="cli-alpine-arm64" ;; \
         "linux/arm/v7") CLI_OS_PKG="cli-linux-armhf"  ;; \
         *)              CLI_OS_PKG="not-supported"    ;; \
    esac \
 && wget -q https://code.visualstudio.com/sha/download?build=stable&os=${CLI_OS_PKG} -O /tmp/vscode_cli.tar.gz \
 && tar -xzf /tmp/vscode_cli.tar.gz -C /usr/bin \
 && chmod +x /usr/bin/code \
 && rm /tmp/vscode_cli.tar.gz

RUN adduser -D $PROJECT

ENV PROJECT_DIR="/home/${PROJECT}"

USER $PROJECT
WORKDIR $PROJECT_DIR
VOLUME $PROJECT_DIR

ENTRYPOINT ["code", "tunnel", "service", "install", "--accept-server-license-terms", "--disable-telemetry"]
