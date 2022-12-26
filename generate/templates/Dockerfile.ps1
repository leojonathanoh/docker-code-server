@"
FROM $( $VARIANT['_metadata']['distro'] ):$( $VARIANT['_metadata']['distro_version'] )
ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN echo "I am running on `$BUILDPLATFORM, building for `$TARGETPLATFORM"

RUN DEPS='alpine-sdk bash libstdc++ libc6-compat python3' \
    && apk add --no-cache `$DEPS \
    && apk add --no-cache npm nodejs \
    && npm config set python python3 \
    && npm install --global code-server@$( $VARIANT['_metadata']['package_version'] ) --unsafe-perm \
    # Fix missing dependencies. See: https://github.com/coder/code-server/issues/5530
    && cd /usr/local/lib/node_modules/code-server/lib/vscode && npm install --legacy-peer-deps \
    && code-server --version \
    && apk del `$DEPS

RUN apk add --no-cache bash ca-certificates curl git git-lfs jq nano openssh-client tree

RUN apk add --no-cache sudo
RUN adduser -u 1000 --gecos '' -D user
RUN echo 'user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/user

ENV LANG=en_US.UTF-8
USER 1000
WORKDIR /home/user
CMD [ "code-server", "--bind-addr", "0.0.0.0:8080", "--disable-telemetry", "--disable-update-check" ]
"@
