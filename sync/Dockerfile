ARG PORT=6001

FROM node:24-trixie-slim AS node

FROM clojure:temurin-21-tools-deps-1.12.4.1618-trixie-slim AS build
COPY --from=node /usr/local /usr/local
RUN corepack enable pnpm

WORKDIR /src
ARG LOGSEQ_REF
RUN git init -q \
  && git fetch --depth 1 https://github.com/logseq/logseq.git "${LOGSEQ_REF}" \
  && git checkout -q --detach FETCH_HEAD

WORKDIR /src/deps/db-sync
RUN --mount=type=cache,target=/root/.local/share/pnpm/store pnpm install --frozen-lockfile --ignore-workspace
RUN --mount=type=cache,target=/root/.m2/repository pnpm run build:node-adapter
RUN CI=true pnpm prune --prod --ignore-workspace
RUN mkdir /tmp/data

FROM gcr.io/distroless/nodejs24-debian13:nonroot
WORKDIR /app

COPY --from=build /src/deps/db-sync/package.json ./
COPY --from=build /src/deps/db-sync/node_modules ./node_modules
COPY --from=build /src/deps/db-sync/worker ./worker
COPY --from=build --chown=nonroot:nonroot /tmp/data /data

ARG PORT
ENV DB_SYNC_PORT=${PORT} DB_SYNC_DATA_DIR=/data

EXPOSE ${PORT}
CMD ["worker/dist/node-adapter.js"]
