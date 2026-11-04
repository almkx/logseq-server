ARG PORT=6003

FROM node:24-trixie-slim AS node

FROM clojure:temurin-21-tools-deps-1.12.4.1618-trixie-slim AS build
COPY --from=node /usr/local /usr/local
RUN corepack enable pnpm

WORKDIR /src
ARG LOGSEQ_REF
RUN git init -q \
  && git fetch --depth 1 https://github.com/logseq/logseq.git "${LOGSEQ_REF}" \
  && git checkout -q --detach FETCH_HEAD

RUN --mount=type=cache,target=/root/.local/share/pnpm/store pnpm install --frozen-lockfile
RUN --mount=type=cache,target=/root/.m2/repository \
    pnpm run gulp:build \
  && clojure -M:cljs release app db-worker \
  && pnpm run webpack-app-build \
  && find static -type f -name '*.map' -delete

FROM nginxinc/nginx-unprivileged:stable-alpine
# The image's entrypoint renders templates (substituting ${PORT}) into conf.d.
COPY web/nginx.conf /etc/nginx/templates/default.conf.template
COPY --from=build /src/static/ /usr/share/nginx/html/

ARG PORT
ENV PORT=${PORT}
EXPOSE ${PORT}
