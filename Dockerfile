FROM node:22-slim AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:22-slim

WORKDIR /app

COPY --from=builder /app/package.json /app/package-lock.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/drizzle.config.ts ./
COPY --from=builder /app/src/infrastructure/db/schema.ts ./src/infrastructure/db/schema.ts

EXPOSE 3000

CMD ["sh", "-c", "npx drizzle-kit push && node dist/src/index.js"]
