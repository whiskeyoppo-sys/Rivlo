import { z } from "zod";

const baseSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().url().optional(),
  OTEL_SERVICE_NAMESPACE: z.string().default("risn"),
  OTEL_RESOURCE_ATTRIBUTES: z.string().optional(),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().default("redis://localhost:6379"),
  STRIPE_SECRET_KEY: z.string().min(1),
  STRIPE_WEBHOOK_SECRET: z.string().min(1),
  STRIPE_PUBLISHABLE_KEY: z.string().min(1),
  NEXT_PUBLIC_API_URL: z.string().url().optional(),
  NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY: z.string().optional(),
  DATA_RETENTION_DAYS: z.coerce.number().int().positive().default(365),
  PRIVACY_DEFAULT_TRACKING: z.enum(["opt_in", "opt_out"]).default("opt_in")
});

export type AppEnv = z.infer<typeof baseSchema>;

let cached: AppEnv | null = null;

export function loadEnv(from: NodeJS.ProcessEnv = process.env): AppEnv {
  if (cached) return cached;
  const parsed = baseSchema.safeParse(from);
  if (!parsed.success) {
    const issues = parsed.error.issues.map(i => `${i.path.join(".")}: ${i.message}`).join(", ");
    throw new Error(`Invalid environment variables: ${issues}`);
  }
  cached = parsed.data;
  return cached;
}

export function getEnv(): AppEnv {
  if (!cached) return loadEnv();
  return cached;
}
