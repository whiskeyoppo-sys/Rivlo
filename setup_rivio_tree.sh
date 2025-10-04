#!/usr/bin/env bash
set -euo pipefail

ROOT="rivio-ecommerce-store"
echo "Creating repo tree at ./${ROOT} ..."

# create directories (top-level + many subfolders)
mkdir -p "${ROOT}"
cd "${ROOT}"

# top-level files and folders
mkdir -p .husky .github/workflows frontend/pages frontend/components frontend/public/images frontend/styles backend/prisma backend/src/config backend/src/common/guards backend/src/common/interceptors backend/src/auth backend/src/users backend/src/products backend/src/cart backend/src/checkout backend/src/orders backend/src/telemetry services/cart/src services/search/src services/recommendations/src services/pricing packages/types/src packages/utils/src packages/ui/src/packages/ui/src/components infra/docker infra/terraform infra/k8s docs/runbooks scripts/dev-helpers scripts/release scripts/generate tests/unit/backend tests/e2e playground/ai-sandbox

# 1) Root package.json
cat > package.json <<'EOF'
{
  "name": "rivio-ecommerce-store-monorepo",
  "version": "0.1.0",
  "private": true,
  "packageManager": "pnpm@8.9.0",
  "workspaces": [
    "frontend",
    "backend",
    "services/*",
    "packages/*",
    "infra",
    "docs",
    "scripts"
  ],
  "scripts": {
    "bootstrap": "pnpm install",
    "dev": "pnpm -w -r --parallel run dev",
    "dev:frontend": "pnpm --filter frontend dev",
    "dev:backend": "pnpm --filter backend start:dev",
    "build": "pnpm -w -r run build",
    "lint": "pnpm -w -r run lint",
    "format": "pnpm -w -r run format",
    "test": "pnpm -w -r run test",
    "migrate": "pnpm --filter backend run migrate",
    "seed": "pnpm --filter backend run seed",
    "prepare": "husky install",
    "clean": "rimraf node_modules **/node_modules .turbo .next dist"
  },
  "devDependencies": {
    "typescript": "^5.4.2",
    "eslint": "^8.40.0",
    "prettier": "^2.8.8",
    "husky": "^8.0.0",
    "lint-staged": "^14.0.0",
    "rimraf": "^5.0.0",
    "concurrently": "^8.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  },
  "risn_meta": {
    "generated_by": "assistant",
    "notes": "Root package.json for PNPM workspace. 'Imported' logic: none. 'New' logic: workspace configuration, workspace-level scripts (dev/build/test/migrate), and lightweight devDependencies. Add workspace-local package.json files for each package (frontend, backend, etc.)."
  }
}
EOF

# 2) .gitignore
cat > .gitignore <<'EOF'
node_modules
dist
.env
.env.local
.pnpm-store
.pnpm-debug.log
pnpm-lock.yaml
.vscode
.next
.DS_Store
coverage
EOF

# 3) README.md (starter)
cat > README.md <<'EOF'
# rivio-ecommerce-store

Monorepo scaffold for a headless e-commerce platform (frontend, backend, services, infra).

This repo was created by an automated script. Populate further per your needs.

Quick start (after installing pnpm):
\`\`\`bash
pnpm install
pnpm dev
\`\`\`
EOF

# 4) LICENSE (MIT placeholder)
cat > LICENSE <<'EOF'
MIT License

Copyright (c) $(date +%Y) Rivio

Permission is hereby granted, free of charge, to any person obtaining a copy
...
EOF

# 5) .env.example
cat > .env.example <<'EOF'
DATABASE_URL=postgres://user:password@localhost:5432/rivio
REDIS_URL=redis://localhost:6379
NEXT_PUBLIC_API_URL=http://localhost:4000
STRIPE_SECRET_KEY=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
JWT_SECRET=change_me
EOF

# 6) .github workflows placeholders
cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
      - name: Install pnpm
        run: npm i -g pnpm
      - name: Install dependencies
        run: pnpm install
EOF

cat > .github/workflows/cd.yml <<'EOF'
name: CD
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Placeholder deployment job
        run: echo "Add deploy steps to host platform"
EOF

# 7) frontend minimal package.json
cat > frontend/package.json <<'EOF'
{
  "name": "rivio-frontend",
  "private": true,
  "version": "0.0.0",
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "14.0.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  }
}
EOF

# 8) frontend/next.config.js (content you requested earlier)
cat > frontend/next.config.js <<'EOF'
/**
 * Imported: base Next.js runtime features (reactStrictMode, swcMinify)
 * New: project-specific rewrites, headers, image domains, and env fallbacks.
 *
 * Design notes & tradeoffs:
 *  - Rewrites for /api/* -> backend reduce CORS friction during development.
 *  - output: 'standalone' is chosen to ease Docker builds and small server bundles.
 *  - Images domains include a local CDN host plus common public hosts; extend as you add an asset pipeline.
 *  - Security headers are conservative but simple; adopt CSP when templates are finalized.
 *
 * Risk notes:
 *  - Using runtime env-based rewrites means you must set NEXT_PUBLIC_API_URL in Vercel/Railway in production.
 *  - If you rely on server-side rendering for checkout pages, ensure session cookies / auth flows align with backend domain and cookie settings.
 */

const isProd = process.env.NODE_ENV === "production";

module.exports = {
  reactStrictMode: true,
  swcMinify: true,
  // Standalone output is friendly for Dockerized Node server deployments.
  output: "standalone",
  images: {
    // Add your CDN or image hostnames here. Adjust as your CDN choice changes.
    domains: ["cdn.rivio.local", "images.unsplash.com", "res.cloudinary.com"]
  },
  env: {
    // Frontend-visible API URL; used by client-side fetches.
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000",
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY:
      process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || ""
  },
  async rewrites() {
    // Proxy /api/* to backend during development — cleaner DX.
    return [
      {
        source: "/api/:path*",
        destination: `${process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000"}/api/:path*`
      }
    ];
  },
  async headers() {
    // Minimal security headers. Replace/extend with a robust CSP later.
    return [
      {
        source: "/(.*)",
        headers: [
          { key: "X-Frame-Options", value: "DENY" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "no-referrer-when-downgrade" }
        ]
      }
    ];
  }
};
EOF

# 9) frontend pages and components (the twisted pieces)
cat > frontend/pages/index.tsx <<'EOF'
/**
 * Twisted landing page (demo).
 */
import React, { useEffect, useState } from "react";
import Head from "next/head";
import TwistedHero from "../components/TwistedHero";
import ProductCard from "../components/ProductCard";
import CartPet from "../components/CartPet";

type Product = {
  id: string;
  title: string;
  price: number;
  images: string[];
  description?: string;
};

export default function Home() {
  const [products, setProducts] = useState<Product[]>([]);
  const apiUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";

  useEffect(() => {
    const sample: Product[] = [
      {
        id: "p-spectral-sneaker",
        title: "Spectral Runner — Color-shifts in low light",
        price: 129.0,
        images: ["/images/sample-sneaker.jpg"],
        description: "A shoe for people who refuse to stay in one mood."
      },
      {
        id: "p-lumen-lamp",
        title: "Lumen Lamp — Blink to your favorite playlist",
        price: 89.0,
        images: ["/images/sample-lamp.jpg"],
        description: "Smart enough to be annoying. Charming enough to keep."
      },
      {
        id: "p-velvet-throw",
        title: "Velvet Throw — Stealth comfort",
        price: 49.5,
        images: ["/images/sample-throw.jpg"],
        description: "Wrap up and pretend to be cultured."
      }
    ];
    setProducts(sample);
  }, [apiUrl]);

  return (
    <>
      <Head>
        <title>Rivio — Twisted Storefront</title>
        <meta name="description" content="Experimental headless storefront — charmingly twisted." />
      </Head>
      <main className="min-h-screen bg-gradient-to-b from-gray-50 to-white">
        <TwistedHero />
        <section className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-2xl font-extrabold">Featured oddities</h2>
            <CartPet />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {products.map((p) => (
              <ProductCard key={p.id} product={p} />
            ))}
          </div>
        </section>
      </main>
    </>
  );
}
EOF

cat > frontend/components/TwistedHero.tsx <<'EOF'
/**
 * TwistedHero: animated hero
 */
import React from "react";
import { motion, AnimatePresence } from "framer-motion";

export default function TwistedHero() {
  const hasOffer = true;
  const discountPct = 11;

  return (
    <section className="relative overflow-hidden bg-gradient-to-r from-purple-600 to-pink-500 text-white">
      <div className="max-w-6xl mx-auto px-4 py-12 sm:py-20 flex flex-col lg:flex-row items-center gap-8">
        <div className="flex-1">
          <h1 className="text-3xl sm:text-5xl font-extrabold leading-tight">
            RIVIO — where products twitch with personality
          </h1>
          <p className="mt-4 text-lg sm:text-xl max-w-xl opacity-90">
            A slightly unreliable storefront that promises character and occasionally recalculates reality.
          </p>

          <div className="mt-6 flex items-center gap-3">
            <a
              href="#"
              className="inline-flex items-center px-4 py-2 rounded-md bg-white/10 hover:bg-white/20 backdrop-blur-sm text-sm font-medium"
            >
              Browse the oddities
            </a>

            {hasOffer && (
              <AnimatePresence>
                <motion.div
                  initial={{ opacity: 0, y: -8, scale: 0.98 }}
                  animate={{ opacity: 1, y: 0, scale: 1 }}
                  exit={{ opacity: 0 }}
                  className="inline-flex items-center gap-2 rounded-full px-3 py-1 bg-white/10 text-sm"
                  aria-hidden
                >
                  <span className="font-semibold">{discountPct}%</span>
                  <span className="opacity-80">off — ephemeral</span>
                </motion.div>
              </AnimatePresence>
            )}
          </div>
        </div>

        <div className="w-full lg:w-1/3">
          <div className="rounded-xl p-4 bg-white/10">
            <div className="aspect-w-4 aspect-h-3 bg-white/5 rounded-md flex items-center justify-center">
              <p className="text-center text-sm opacity-90 max-w-xs">
                Product spotlight — images populate here. Replace with next/image bound to your image CDN.
              </p>
            </div>
            <div className="mt-3 text-xs opacity-80">
              <strong>Note:</strong> The "time-bending" discount is purely decorative in the UI and must be validated at checkout.
            </div>
          </div>
        </div>
      </div>

      <svg className="absolute right-0 top-0 -mt-6 -mr-6 w-64 h-64 opacity-20" viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="50" fill="white" />
      </svg>
    </section>
  );
}
EOF

cat > frontend/components/CartPet.tsx <<'EOF'
/**
 * CartPet: tiny cart UX pet
 */
import React, { useEffect, useState } from "react";

const LS_KEY = "rivio:cartpet";

type PetState = {
  level: number;
  lastUpdated: number;
};

function safeReadLS<T>(key: string, fallback: T): T {
  try {
    const raw = localStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T) : fallback;
  } catch {
    return fallback;
  }
}

export default function CartPet() {
  const [count, setCount] = useState(0);
  const [pet, setPet] = useState<PetState>({ level: 0, lastUpdated: Date.now() });

  useEffect(() => {
    const stored = typeof window !== "undefined" ? safeReadLS(LS_KEY, { level: 0, lastUpdated: Date.now() }) : { level: 0, lastUpdated: Date.now() };
    setPet(stored);
    setCount(stored.level * 2);
  }, []);

  function addToCartDemo() {
    const newLevel = Math.min(5, pet.level + 1);
    const next = { level: newLevel, lastUpdated: Date.now() };
    try {
      localStorage.setItem(LS_KEY, JSON.stringify(next));
    } catch {
    }
    setPet(next);
    setCount(newLevel * 2);
  }

  const size = 24 + pet.level * 6;

  return (
    <div className="flex items-center gap-3">
      <button
        onClick={() => (window.location.href = "/cart")}
        aria-label="Open cart"
        className="relative inline-flex items-center px-3 py-1 rounded-full bg-white/10 hover:bg-white/20 text-sm"
      >
        <div style={{ width: size, height: size }} className="rounded-full bg-white/20 flex items-center justify-center text-xs font-bold">
          🐾
        </div>
        <span className="ml-2 font-medium">{count}</span>
      </button>

      <button
        onClick={addToCartDemo}
        className="px-3 py-1 rounded-md bg-white/6 text-xs"
        title="Demo: add to cart (affects pet)"
      >
        + demo
      </button>
    </div>
  );
}
EOF

cat > frontend/components/ProductCard.tsx <<'EOF'
/**
 * ProductCard: simple card component
 */
import React, { useState } from "react";

type Product = {
  id: string;
  title: string;
  price: number;
  images: string[];
  description?: string;
};

export default function ProductCard({ product }: { product: Product }) {
  const [qty, setQty] = useState(1);

  function getAIDescription() {
    if (product.description) return product.description;
    return "A short, playful description would appear here if your AI keys found true meaning in corporate product copy.";
  }

  return (
    <article className="bg-white rounded-lg shadow-sm p-4 flex flex-col">
      <div className="aspect-w-4 aspect-h-3 bg-gray-50 rounded-md overflow-hidden flex items-center justify-center">
        <img src={product.images?.[0] || "/images/placeholder.png"} alt={product.title} className="object-cover w-full h-full" />
      </div>

      <div className="mt-3 flex-1 flex flex-col">
        <h3 className="text-sm font-semibold">{product.title}</h3>
        <div className="mt-2 text-sm text-gray-600 flex-1">{getAIDescription()}</div>

        <div className="mt-4 flex items-center justify-between">
          <div>
            <div className="text-lg font-bold">${product.price.toFixed(2)}</div>
            <div className="text-xs text-gray-500">Inclusive of our charming quirks</div>
          </div>

          <div className="flex items-center gap-2">
            <input
              type="number"
              min={1}
              value={qty}
              onChange={(e) => setQty(Math.max(1, parseInt(e.target.value || "1")))}
              className="w-16 px-2 py-1 border rounded-md text-sm"
            />
            <button
              className="px-3 py-1 rounded-md bg-indigo-600 text-white text-sm"
              onClick={() => {
                alert(`Added ${qty} × ${product.title} to cart (demo).`);
              }}
            >
              Add
            </button>
          </div>
        </div>
      </div>
    </article>
  );
}
EOF

# 10) frontend public placeholders
touch frontend/public/images/sample-sneaker.jpg
touch frontend/public/images/sample-lamp.jpg
touch frontend/public/images/sample-throw.jpg
touch frontend/public/images/placeholder.png
touch frontend/public/favicon.ico

# 11) backend placeholder package.json & prisma schema placeholder
cat > backend/package.json <<'EOF'
{
  "name": "rivio-backend",
  "private": true,
  "version": "0.1.0",
  "scripts": {
    "start:dev": "nest start --watch",
    "migrate": "prisma migrate dev --name init",
    "seed": "ts-node prisma/seed.ts"
  },
  "dependencies": {}
}
EOF

cat > backend/prisma/schema.prisma <<'EOF'
generator client {
  provider = "prisma-client-js"
}
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(uuid())
  email     String   @unique
  password  String
  createdAt DateTime @default(now())
}

model Product {
  id          String   @id @default(uuid())
  title       String
  description String?
  price       Float
  createdAt   DateTime @default(now())
}

model Order {
  id        String   @id @default(uuid())
  userId    String
  total     Float
  createdAt DateTime @default(now())
}
EOF

# 12) minimal placeholders for services and packages
cat > services/cart/package.json <<'EOF'
{
  "name": "rivio-service-cart",
  "version": "0.0.0",
  "private": true
}
EOF
cat > services/search/package.json <<'EOF'
{
  "name": "rivio-service-search",
  "version": "0.0.0",
  "private": true
}
EOF
cat > services/recommendations/package.json <<'EOF'
{
  "name": "rivio-service-recommendations",
  "version": "0.0.0",
  "private": true
}
EOF
cat > packages/types/package.json <<'EOF'
{
  "name": "rivio-types",
  "version": "0.0.0",
  "private": true
}
EOF

cat > packages/types/src/index.ts <<'EOF'
export type Product = {
  id: string;
  title: string;
  price: number;
  description?: string;
};
EOF

# 13) infra docker-compose placeholder
cat > infra/docker/docker-compose.yml <<'EOF'
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: rivio
      POSTGRES_PASSWORD: rivio
      POSTGRES_DB: rivio
    ports:
      - "5432:5432"
  redis:
    image: redis:7
    ports:
      - "6379:6379"
EOF

# 14) docs placeholders
cat > docs/architecture.md <<'EOF'
# Architecture

High level notes for Rivio e-commerce platform.
EOF
cat > docs/dev-setup-termux.md <<'EOF'
# Termux Dev Setup (short)
1. Install node and pnpm.
2. Run pnpm install
3. Run pnpm dev
EOF

# 15) misc configs
cat > tsconfig.base.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true
  },
  "exclude": ["node_modules"]
}
EOF

cat > .eslintrc.cjs <<'EOF'
module.exports = {
  root: true,
  extends: ['eslint:recommended'],
  env: { node: true, es2021: true }
};
EOF

cat > .prettierrc <<'EOF'
{
  "semi": true,
  "singleQuote": true
}
EOF

# 16) scripts placeholders
cat > scripts/dev-helpers/watch-and-reload.sh <<'EOF'
#!/usr/bin/env bash
echo "watch & reload placeholder"
EOF
chmod +x scripts/dev-helpers/watch-and-reload.sh

# 17) tests placeholders
cat > tests/jest.config.js <<'EOF'
module.exports = { testEnvironment: 'node' };
EOF
cat > tests/e2e/playwright.config.ts <<'EOF'
import { defineConfig } from '@playwright/test';
export default defineConfig({});
EOF

# 18) finalize
echo "Repository skeleton created at: $(pwd)"
echo "Next steps:"
echo "  - cd ${ROOT}"
echo "  - install pnpm if you haven't: curl -fsSL https://get.pnpm.io/install.sh | sh -"
echo "  - pnpm install"
echo "  - Customize backend/frontend package.json versions and dependencies"
echo "  - Run 'pnpm dev' once workspaces are populated"
