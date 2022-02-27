import { Global, Module } from '@nestjs/common';
import { JobsHaploRService } from './services/jobs.haplor.service';
import { JobsHaploRController } from './controllers/jobs.haplor.controller';
import { QueueModule } from '../jobqueue/queue.module';
import { JobsHaplorNoauthController } from './controllers/jobs.haplor.noauth.controller';

@Global()
@Module({
  imports: [QueueModule],
  controllers: [JobsHaploRController, JobsHaplorNoauthController],
  providers: [JobsHaploRService],
  exports: [],
})
export class JobsModule {}
