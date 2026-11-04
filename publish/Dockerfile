ARG PORT=6002

FROM node:24-trixie-slim AS node

FROM clojure:temurin-21-tools-deps-1.12.4.1618-trixie-slim AS build
COPY --from=node /usr/local /usr/local
RUN corepack enable pnpm

WORKDIR /src
ARG LOGSEQ_REF
RUN git init -q \
  && git fetch --depth 1 https://github.com/logseq/logseq.git "${LOGSEQ_REF}" \
  && git checkout -q --detach FETCH_HEAD

WORKDIR /src/deps/publish
RUN --mount=type=cache,target=/root/.local/share/pnpm/store pnpm install --frozen-lockfile --ignore-workspace \
  && cp -a "$(readlink -f node_modules/mldoc)" /tmp/mldoc
RUN --mount=type=cache,target=/root/.m2/repository pnpm run release

FROM node

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*
RUN --mount=type=cache,target=/root/.npm npm install -g wrangler@4.155.0
RUN mkdir -p /app/worker /data && chown -R node:node /app /data

WORKDIR /app/worker
COPY --from=build --chown=node:node /tmp/mldoc ./node_modules/mldoc
COPY --from=build --chown=node:node /src/deps/publish/worker ./
COPY --chown=node:node publish/wrangler.toml ./

ARG PORT
ENV HOME=/data/home \
    PORT=${PORT} \
    CLOUDFLARE_INCLUDE_PROCESS_ENV=true \
    WRANGLER_LOG=info \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

USER node
EXPOSE ${PORT}
CMD exec wrangler dev --ip 0.0.0.0 --port "$PORT" --persist-to /data/wrangler
