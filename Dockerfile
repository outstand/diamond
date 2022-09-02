ARG ELIXIR_IMAGE="hexpm/elixir:1.14.0-erlang-25.0.4-ubuntu-jammy-20220428"

FROM ${ELIXIR_IMAGE} as build
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
      \
      apt-get update -y; \
      apt-get install -y \
        ca-certificates \
        curl \
        git \
      ; \
      apt-get clean; \
      rm -f /var/lib/apt/lists/*_*

ARG ELIXIR_LS_VER=0.11.0
RUN curl -fsSL https://github.com/elixir-lsp/elixir-ls/archive/refs/tags/v$ELIXIR_LS_VER.tar.gz -o $ELIXIR_LS_VER.tar.gz
# RUN curl -fsSL https://github.com/elixir-lsp/elixir-ls/archive/$ELIXIR_LS_VER.tar.gz -o $ELIXIR_LS_VER.tar.gz
RUN tar -xf $ELIXIR_LS_VER.tar.gz && \
    cd elixir-ls-$ELIXIR_LS_VER && \
    mix local.hex --force && mix local.rebar --force && \
    mix do deps.get, compile, elixir_ls.release -o /opt/elixir-ls

FROM outstand/su-exec:latest as su-exec
FROM outstand/fixuid:latest as fixuid

FROM ${ELIXIR_IMAGE}
LABEL maintainer="Ryan Schlesinger <ryan@outstand.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# install system deps
RUN set -eux; \
      \
      apt-get update -y; \
      apt-get install -y \
        curl \
        ca-certificates \
      ; \
      \
      curl -fsSL https://deb.nodesource.com/setup_16.x | bash -; \
      \
      apt-get update -y; \
      apt-get install -y \
        build-essential \
        tini \
        git \
        nodejs \
        python3 \
        inotify-tools \
      ; \
      \
      curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null; \
      echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list; \
      apt-get update -y; \
      apt-get install -y \
        yarn \
      ; \
      apt-get clean; \
      rm -f /var/lib/apt/lists/*_*

# install su-exec
COPY --from=su-exec /sbin/su-exec /sbin/su-exec

# install fixuid
COPY --from=fixuid /usr/local/bin/fixuid /usr/local/bin/fixuid
COPY --from=fixuid /etc/fixuid/config.yml /etc/fixuid/config.yml
RUN chmod 4755 /usr/local/bin/fixuid

# install elixir-ls
COPY --from=build /opt/elixir-ls /opt/elixir-ls
RUN chmod a+x /opt/elixir-ls/*.sh

# setup deploy user and hex
RUN set -eux; \
      \
      groupadd -g 1000 deploy; \
      useradd -u 1000 -g deploy -ms /bin/bash deploy; \
      \
      su-exec deploy mix local.hex --force; \
      su-exec deploy mix local.rebar --force

COPY docker/tools-entrypoint.sh /tools-entrypoint.sh
COPY docker/entrypoint.sh /docker-entrypoint.sh

EXPOSE 4000
ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/docker-entrypoint.sh"]
CMD ["mix", "phx.server"]
