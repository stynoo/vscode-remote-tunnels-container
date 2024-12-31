FROM alpine:3

ENV PROJECT="vscode-tunnels"
ENV PROJECT_DIR="/home/${PROJECT}"

RUN apk --no-cache add git libstdc++

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
    && chown -R $PROJECT:$PROJECT $PROJECT_DIR

USER $PROJECT
WORKDIR $PROJECT_DIR
VOLUME $PROJECT_DIR

ENTRYPOINT ["code", "tunnel", "--accept-server-license-terms", "--disable-telemetry"]
