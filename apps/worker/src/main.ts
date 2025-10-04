import { Queue, Worker, QueueEvents, JobsOptions } from "bullmq";
import Redis from "ioredis";

const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";
const connection = new Redis(redisUrl);

const queueName = "risn-jobs";
const queue = new Queue(queueName, { connection });
const queueEvents = new QueueEvents(queueName, { connection });

queueEvents.on("completed", ({ jobId }) => {
  console.log(`Job ${jobId} completed`);
});

queueEvents.on("failed", ({ jobId, failedReason }) => {
  console.error(`Job ${jobId} failed: ${failedReason}`);
});

const worker = new Worker(
  queueName,
  async (job) => {
    if (job.name === "email-receipt") {
      // Placeholder for email sending logic
      await new Promise((resolve) => setTimeout(resolve, 100));
      return { ok: true };
    }
    return { ok: true };
  },
  { connection }
);

async function enqueueDemo() {
  const opts: JobsOptions = { removeOnComplete: true, removeOnFail: 100 };
  await queue.add("email-receipt", { orderId: "demo-order" }, opts);
}

if (process.env.NODE_ENV !== "production") {
  enqueueDemo().catch((err) => console.error(err));
}

process.on("SIGINT", async () => {
  await worker.close();
  await queue.close();
  await queueEvents.close();
  await connection.quit();
  process.exit(0);
});
