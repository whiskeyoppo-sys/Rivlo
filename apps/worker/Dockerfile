# Build Worker from monorepo root context
FROM node:20-alpine AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.7.0 --activate

FROM base AS deps
COPY package.json pnpm-workspace.yaml turbo.json tsconfig.base.json ./
COPY apps ./apps
COPY packages ./packages
RUN pnpm install

FROM deps AS build
RUN pnpm --filter worker build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/apps/worker/dist ./dist
COPY apps/worker/package.json ./package.json
RUN corepack enable && corepack prepare pnpm@9.7.0 --activate && pnpm install --prod --ignore-scripts
CMD ["node", "dist/main.js"]
