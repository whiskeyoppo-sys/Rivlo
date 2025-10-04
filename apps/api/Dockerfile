# Build API from monorepo root context
FROM node:20-alpine AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.7.0 --activate

FROM base AS deps
COPY package.json pnpm-workspace.yaml turbo.json tsconfig.base.json ./
COPY apps ./apps
COPY packages ./packages
RUN pnpm install

FROM deps AS build
RUN pnpm --filter api build

FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/apps/api/dist ./dist
COPY apps/api/package.json ./package.json
RUN corepack enable && corepack prepare pnpm@9.7.0 --activate && pnpm install --prod --ignore-scripts
EXPOSE 3001
CMD ["node", "dist/main.js"]
