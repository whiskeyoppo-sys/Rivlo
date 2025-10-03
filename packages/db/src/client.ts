import { PrismaClient } from "@prisma/client";

declare global {
  // eslint-disable-next-line no-var
  var __prismaClient: PrismaClient | undefined;
}

export function getPrismaClient(): PrismaClient {
  if (process.env.NODE_ENV === "production") {
    return new PrismaClient({ log: ["error", "warn"] });
  }
  if (!global.__prismaClient) {
    global.__prismaClient = new PrismaClient({ log: ["error", "warn"] });
  }
  return global.__prismaClient;
}
