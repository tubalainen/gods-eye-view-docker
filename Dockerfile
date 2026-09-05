# syntax=docker/dockerfile:1

ARG GEV_REPOSITORY=https://github.com/bilawalsidhu/gods-eye-view.git
ARG GEV_REF=main

FROM alpine/git:2.49.1 AS source
ARG GEV_REPOSITORY
ARG GEV_REF
RUN git init /source \
    && git -C /source remote add origin "${GEV_REPOSITORY}" \
    && git -C /source fetch --depth 1 origin "${GEV_REF}" \
    && git -C /source checkout --detach FETCH_HEAD \
    && rm -rf /source/.git

FROM node:24-alpine AS dependencies
WORKDIR /app
ENV PUPPETEER_SKIP_DOWNLOAD=true
COPY --from=source /source/package.json /source/package-lock.json ./
RUN npm ci --no-audit --no-fund

FROM node:24-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=4173

RUN apk add --no-cache su-exec

LABEL org.opencontainers.image.source="https://github.com/tubalainen/gods-eye-view-docker" \
      org.opencontainers.image.url="https://github.com/bilawalsidhu/gods-eye-view" \
      org.opencontainers.image.licenses="MIT"

COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules
COPY --from=source --chown=node:node /source/ ./

# Keep mutable runtime data outside the application tree. The symlinks let the
# unmodified upstream application continue using its normal paths.
RUN mkdir -p /data/cache /data/logs \
    && touch /data/.env \
    && chown -R node:node /data \
    && chown node:node /app \
    && ln -s /data/cache /app/.gev-cache \
    && ln -s /data/logs /app/.gev-logs \
    && ln -s /data/.env /app/.env

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/gev-entrypoint

ENTRYPOINT ["/usr/local/bin/gev-entrypoint"]
EXPOSE 4173

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||4173)+'/').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"

CMD ["node", "node_modules/vite/bin/vite.js"]
