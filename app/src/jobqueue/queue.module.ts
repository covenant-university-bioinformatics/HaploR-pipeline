import { Inject, Module, OnModuleInit } from '@nestjs/common';
import { createWorkers } from '../workers/haplor.main';
import { HaploRJobQueue } from './queue/haplor.queue';
import { NatsModule } from '../nats/nats.module';
import { JobCompletedPublisher } from '../nats/publishers/job-completed-publisher';

@Module({
  imports: [NatsModule],
  providers: [HaploRJobQueue],
  exports: [HaploRJobQueue],
})
export class QueueModule implements OnModuleInit {
  @Inject(JobCompletedPublisher) jobCompletedPublisher: JobCompletedPublisher;
  async onModuleInit() {
    await createWorkers(this.jobCompletedPublisher);
  }
}
