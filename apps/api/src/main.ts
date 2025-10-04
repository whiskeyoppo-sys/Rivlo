import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { json } from 'express';
import { initTelemetry } from '@repo/observability';

async function bootstrap() {
  initTelemetry('api');
  const app = await NestFactory.create(AppModule, { rawBody: true });
  app.use(json({ verify: (req: any, _res, buf) => { req.rawBody = buf.toString(); } }));
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
