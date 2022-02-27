import * as mongoose from 'mongoose';

export enum Populations {
  AFR = 'AFR',
  AMR = 'AMR',
  EUR = 'EUR',
  EAS = 'EAS',
  SAS = 'SAS',
}

export enum AnalysisOptions {
  HAPLOREG = 'HaploReg',
  REGULOME = 'Regulome',
}

export enum EPIOptions {
  VANILLA = 'vanilla',
  IMPUTED = 'imputed',
  METHYL = 'methyl',
}

export enum CONSOptions {
  GERP = 'gerp',
  SIPHY = 'siphy',
  BOTH = 'both',
}

export enum GenetypeOptions {
  GENECODE = 'gencode',
  REFSEQ = 'refseq',
}

export enum GenomeAssembly {
  GRCh37 = '37',
  GRCh38 = '38',
}

//Interface that describe the properties that are required to create a new job
interface HaploRAttrs {
  job: string;
  useTest: string;
  analysisType: AnalysisOptions;
  marker_name?: string;
  ldThresh?: string;
  ldPop?: Populations;
  epi?: EPIOptions;
  cons?: CONSOptions;
  genetypes?: GenetypeOptions;
  snpID?: string;
  genomeAssembly?: GenomeAssembly;
}

// An interface that describes the extra properties that a eqtl model has
//collection level methods
interface HaploRModel extends mongoose.Model<HaploRDoc> {
  build(attrs: HaploRAttrs): HaploRDoc;
}

//An interface that describes a properties that a document has
export interface HaploRDoc extends mongoose.Document {
  id: string;
  version: number;
  useTest: boolean;
  analysisType: AnalysisOptions;
  marker_name?: number;
  ldThresh?: number;
  ldPop?: Populations;
  epi?: EPIOptions;
  cons?: CONSOptions;
  genetypes?: GenetypeOptions;
  snpID?: string;
  genomeAssembly?: GenomeAssembly;
}

const HaploRSchema = new mongoose.Schema<HaploRDoc, HaploRModel>(
  {
    useTest: {
      type: Boolean,
      trim: true,
    },
    marker_name: {
      type: Number,
      trim: true,
    },
    ldPop: {
      type: String,
      enum: [
        Populations.AFR,
        Populations.AMR,
        Populations.EUR,
        Populations.EAS,
        Populations.SAS,
      ],
      trim: true,
    },
    analysisType: {
      type: String,
      enum: [AnalysisOptions.HAPLOREG, AnalysisOptions.REGULOME],
      trim: true,
      required: [true, 'Please add a analysis type'],
    },
    ldThresh: {
      type: Number,
      trim: true,
    },
    epi: {
      type: String,
      enum: [EPIOptions.IMPUTED, EPIOptions.VANILLA, EPIOptions.METHYL],
      trim: true,
    },
    cons: {
      type: String,
      enum: [CONSOptions.GERP, CONSOptions.SIPHY, CONSOptions.BOTH],
      trim: true,
    },
    genetypes: {
      type: String,
      enum: [GenetypeOptions.GENECODE, GenetypeOptions.REFSEQ],
      trim: true,
    },
    snpID: {
      type: String,
      trim: true,
    },
    genomeAssembly: {
      type: String,
      enum: [GenomeAssembly.GRCh37, GenomeAssembly.GRCh38],
      trim: true,
    },
    job: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'HaploRJob',
      required: true,
    },
    version: {
      type: Number,
    },
  },
  {
    timestamps: true,
    versionKey: 'version',
    toJSON: {
      transform(doc, ret) {
        ret.id = ret._id;
        // delete ret._id;
        // delete ret.__v;
      },
    },
  },
);

//increments version when document updates
HaploRSchema.set('versionKey', 'version');

//collection level methods
HaploRSchema.statics.build = (attrs: HaploRAttrs) => {
  return new HaploRModel(attrs);
};

//create mongoose model
const HaploRModel = mongoose.model<HaploRDoc, HaploRModel>(
  'HaploR',
  HaploRSchema,
  'haplors',
);

export { HaploRModel };
