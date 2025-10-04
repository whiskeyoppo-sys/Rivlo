import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PaymentsController } from './payments/payments.controller';
import { StylistController } from './stylist/stylist.controller';
import { LiveController } from './live/live.controller';

@Module({
  imports: [],
  controllers: [AppController, PaymentsController, StylistController, LiveController],
  providers: [AppService],
})
export class AppModule {}
