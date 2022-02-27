import { SandboxedJob } from 'bullmq';
import * as fs from 'fs';
import { JobStatus, HaploRJobsModel } from '../jobs/models/haplor.jobs.model';
import {
  AnalysisOptions,
  HaploRDoc,
  HaploRModel,
} from '../jobs/models/haplor.model';
import appConfig from '../config/app.config';
import { spawnSync } from 'child_process';
import connectDB, { closeDB } from '../mongoose';

import {
  deleteFileorFolder,
  fileOrPathExists,
  writeHaploRFile,
  writeLDFile,
} from '@cubrepgwas/pgwascommon';

function sleep(ms) {
  console.log('sleeping');
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getJobParameters(
  analysisType: AnalysisOptions,
  parameters: HaploRDoc,
) {
  switch (analysisType) {
    case AnalysisOptions.HAPLOREG:
      return [
        String(parameters.analysisType),
        String(parameters.ldThresh),
        String(parameters.ldPop),
        String(parameters.epi),
        String(parameters.cons),
        String(parameters.genetypes),
      ];
    case AnalysisOptions.REGULOME:
      return [
        String(parameters.analysisType),
        String(parameters.snpID),
        String(parameters.genomeAssembly),
      ];
  }
}

export default async (job: SandboxedJob) => {
  //executed for each job
  console.log(
    'Worker ' +
      ' processing job ' +
      JSON.stringify(job.data.jobId) +
      ' Job name: ' +
      JSON.stringify(job.data.jobName),
  );

  await connectDB();
  await sleep(2000);

  //fetch job parameters from database
  const parameters = await HaploRModel.findOne({
    job: job.data.jobId,
  }).exec();

  const jobParams = await HaploRJobsModel.findById(job.data.jobId).exec();

  let jobParameters;
  const pathToOutputDir = `/pv/analysis/${job.data.jobUID}/${appConfig.appName}/output`;
  //make output directory
  fs.mkdirSync(pathToOutputDir, { recursive: true });

  if (parameters.analysisType === AnalysisOptions.HAPLOREG) {
    //create input file and folder
    let filename;

    //extract file name
    const name = jobParams.inputFile.split(/(\\|\/)/g).pop();

    filename = `/pv/analysis/${jobParams.jobUID}/input/${name}`;

    //write the exact columns needed by the analysis
    writeHaploRFile(jobParams.inputFile, filename, {
      marker_name: parameters.marker_name - 1,
    });

    deleteFileorFolder(jobParams.inputFile).then(() => {
      console.log('deleted ', jobParams.inputFile);
    });

    await HaploRJobsModel.findByIdAndUpdate(job.data.jobId, {
      inputFile: filename,
    });

    //assemble job parameters
    jobParameters = getJobParameters(parameters.analysisType, parameters);
    jobParameters.splice(1, 0, filename);
    jobParameters.splice(1, 0, pathToOutputDir);
  } else {
    jobParameters = getJobParameters(parameters.analysisType, parameters);
    jobParameters.splice(2, 0, pathToOutputDir);
  }

  // jobParameters.unshift(pathToOutputDir);

  console.log(jobParameters);

  // save in mongo database
  await HaploRJobsModel.findByIdAndUpdate(
    job.data.jobId,
    {
      status: JobStatus.RUNNING,
    },
    { new: true },
  );

  await sleep(3000);
  //spawn process
  const jobSpawn = spawnSync('./pipeline_scripts/haploR.sh', jobParameters, {
    maxBuffer: 1024 * 1024 * 1024,
  });

  console.log('Spawn command log');
  console.log(jobSpawn?.stdout?.toString());
  console.log('=====================================');
  console.log('Spawn error log');
  const error_msg = jobSpawn?.stderr?.toString();
  console.log(error_msg);

  let answer: boolean;

  if (parameters.analysisType === AnalysisOptions.HAPLOREG) {
    const fileOne = await fileOrPathExists(
      `${pathToOutputDir}/Errors_haploR.txt`,
    );
    const fileTwo = await fileOrPathExists(
      `${pathToOutputDir}/results_haploR.txt`,
    );
    answer = fileOne && fileTwo;
  } else if (parameters.analysisType === AnalysisOptions.REGULOME) {
    const fileOne = await fileOrPathExists(
      `${pathToOutputDir}/results_Regulome.txt`,
    );
    const fileTwo = await fileOrPathExists(
      `${pathToOutputDir}/results_Regulome_nearby_snps.txt`,
    );

    answer = fileOne && fileTwo;
  } else {
    answer = false;
  }

  //close database connection
  closeDB();

  console.log(answer);

  if (answer) {
    return true;
  } else {
    throw new Error(error_msg || 'Job failed to successfully complete');
  }

  return true;
};
