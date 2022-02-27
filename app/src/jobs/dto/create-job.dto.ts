import {
  IsNumberString,
  IsString,
  MaxLength,
  MinLength,
  IsEnum,
  IsNotEmpty,
  IsEmail,
  IsOptional,
  IsBooleanString,
} from 'class-validator';
import {
  Populations,
  AnalysisOptions,
  EPIOptions,
  CONSOptions,
  GenetypeOptions,
  GenomeAssembly,
} from '../models/haplor.model';

export class CreateJobDto {
  @IsString()
  @MinLength(5)
  @MaxLength(20)
  job_name: string;

  @IsEmail()
  @IsOptional()
  email: string;

  @IsBooleanString()
  useTest: string;

  @IsNumberString()
  @IsOptional()
  marker_name: string;

  @IsNotEmpty()
  @IsEnum(AnalysisOptions)
  analysisType: AnalysisOptions;

  @IsNumberString()
  @IsOptional()
  ldThresh: string;

  @IsOptional()
  @IsEnum(Populations)
  ldPop: Populations;

  @IsOptional()
  @IsEnum(EPIOptions)
  epi: EPIOptions;

  @IsOptional()
  @IsEnum(CONSOptions)
  cons: CONSOptions;

  @IsOptional()
  @IsEnum(GenetypeOptions)
  genetypes: GenetypeOptions;

  @IsString()
  @IsOptional()
  snpID: string;

  @IsOptional()
  @IsEnum(GenomeAssembly)
  genomeAssembly: GenomeAssembly;
}
