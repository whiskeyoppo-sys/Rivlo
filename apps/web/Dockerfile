# Build Web from monorepo root context
FROM node:20-alpine AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.7.0 --activate

FROM base AS deps
COPY package.json pnpm-workspace.yaml turbo.json tsconfig.base.json ./
COPY apps ./apps
COPY packages ./packages
RUN pnpm install

FROM deps AS build
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm --filter web build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/apps/web/.next ./.next
COPY apps/web/package.json ./package.json
COPY apps/web/public ./public
RUN corepack enable && corepack prepare pnpm@9.7.0 --activate && pnpm install --prod --ignore-scripts
EXPOSE 3000
CMD ["pnpm", "start"]
