# ==========================================
# Stage 1: Build & Dependencies
# ==========================================
FROM node:22-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install --omit=dev

# ==========================================
# Stage 2: Production Distroless / Hardened Runner
# ==========================================
FROM node:22-alpine AS runner

WORKDIR /usr/src/app

ENV NODE_ENV=production
ENV PORT=3002

COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY package*.json ./
COPY src/ ./src/

USER node

EXPOSE 3002

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3002/healthz || exit 1

CMD ["node", "src/server.js"]
