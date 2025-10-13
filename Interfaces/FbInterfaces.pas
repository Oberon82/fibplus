unit FbInterfaces;

interface
uses
  System.Classes;

type

  TAllRowsAffected = record
    Updates: integer;
    Deletes: integer;
    Selects: integer;
    Inserts: integer;
  end;

  IFbAttachment = interface;
  IFbProvider   = interface;
  IFbMessageMetadata = interface;

  IFbStatus = interface
    ['{F369D131-F250-4713-A909-D424FEA3A4FD}']
    function HasErrors: boolean;
    function CheckStatus(ErrorCodes: array of LongInt): Boolean;
    function GetStatus: Integer;
  end;

  IFbAttachmentParams = interface
    ['{296FCF3E-DEAC-4802-8ED8-7CFDF9C79229}']
    procedure GenerateParams(AParams: TStrings; IsFireBird: Boolean);
  end;

  IFbTransactionParams = interface
    ['{80FC062A-7367-4182-A1AD-1410329449F7}']
    procedure GenerateParams(AParams: TStrings; IsFB21orMore: boolean);
    procedure GenerateDistributedParams(Attachment: IFbAttachment; const ATransactionParams: IFbTransactionParams);
  end;

  IFbTransaction = interface
    ['{DCA84E5B-B5A8-4E95-A9C8-F7015AC7E4BE}']
    function GetAttachment: IFbAttachment;
    property Attachment: IFbAttachment read GetAttachment;

    function GetStatus: IFbStatus;
    property Status: IFbStatus read GetStatus;

    procedure Commit;
    procedure CommitRetaining;
    procedure Rollback;
    procedure RollbackRetaining;

    function GetTransactionId: Integer;
  end;

  IFbResultSet = interface
    ['{71F47E7C-D0FB-4B18-8F6F-2A8DFBE14198}']
    procedure Fetch(ASqlDialect: Integer);
  end;

  IFbStatement = interface
    ['{6A0DFBDB-F11F-43E2-83C3-A1E384CC4AC1}']
    function GetAttachment: IFbAttachment;
    property Attachment: IFbAttachment read GetAttachment;

    function GetStatus: IFbStatus;
    property Status: IFbStatus read GetStatus;

    procedure Close;
    procedure Drop;
    procedure Execute(ATransaction: IFbTransaction; ASqlDialect: Integer);
    function OpenCursor(ATransaction: IFbTransaction; ASqlDialect: Integer): IFbResultSet;
    function GetType: Byte;
    procedure SetCursorName(const AName: string);
    function GetInputMetadata(ASqlDialect: integer): IFbMessageMetadata;
    function GetOutputMetadata(ASqlDialect: integer): IFbMessageMetadata;

    function GetPlan: string;
    function GetAllRowsAffected: TAllRowsAffected;
    procedure GetFieldAlias(AList: TStrings);
  end;

  IFbBlob = interface
    ['{CB58D328-FB7E-45EB-8D52-5C2B618C1422}']
    function GetAttachment: IFbAttachment;
    property Attachment: IFbAttachment read GetAttachment;

    function GetStatus: IFbStatus;
    property Status: IFbStatus read GetStatus;
  end;

  IFbArray = interface
    ['{864B82DB-86F6-458F-A012-C0AA9F81CDF4}']
    function GetAttachment: IFbAttachment;
    property Attachment: IFbAttachment read GetAttachment;

    function GetStatus: IFbStatus;
    property Status: IFbStatus read GetStatus;
  end;

//  IFbMessageMetadataItem = interface
//    property Name: string read GetName;
//    property Relation : string read GetRelation;
//    property Owner: string read GetOwner;
//    property Alias: string read GetAlias;
//    property SqlType: Integer read GetSqlType;
//    property IsNullable: Integer read GetIsNullable;
//  end;

  IFbMessageMetadata = interface
    ['{151A88A8-1266-41A5-8ED5-4864D3B8070D}']
    function GetStatus: IFbStatus;
    property Status: IFbStatus read GetStatus;

    function GetCount: Integer;
    function GetField(AIndex: Cardinal): string;
    function GetRelation(AIndex: Cardinal): string;
    function GetOwner(AIndex: Cardinal): string;
    function GetAlias(AIndex: Cardinal): string;
    function GetType(AIndex: Cardinal): Cardinal;
    function IsNullable(AIndex: Cardinal): Boolean;
    function GetSubType(AIndex: Cardinal): Cardinal;
    function GetLenth(AIndex: Cardinal): Cardinal;
    function GetScale(AIndex: Cardinal): Integer;
    function GetCharSet(AIndex: Cardinal): Cardinal;
    function GetOffset(AIndex: Cardinal): Cardinal;
    function GetNullOffset(AIndex: Cardinal): Cardinal;
    function GetMessageLength(AIndex: Cardinal): Cardinal;
  end;

  IFbAttachment = interface
    ['{363A7B48-4FCA-4DC4-9B78-7AC6F43E7FFA}']
    function GetProvider: IFbProvider;
    property Provider: IFbProvider read GetProvider;

    function GetStatus: IFbStatus;
    property Status: IFbStatus read GetStatus;

    procedure DropDatabase;
    procedure DetachDatabase;

    function StartDistributedTransaction(AParams: IFbTransactionParams): IFbTransaction;

    procedure Execute(ATransaction: IFbTransaction; ASql: AnsiString; ASqlDialect: integer);
    procedure CancelOperation(AOptions: Integer);
    function Prepare(ATransaction: IFbTransaction; ASql: AnsiString; ASqlDialect: integer): IFbStatement;

    function GetAttachmentID: LongInt;
    function GetAllocation: LongInt;
    function GetBaseLevel: LongInt;
    function GetDBFileName: Ansistring;
    function GetDBSiteName: Ansistring;
    function GetIsRemoteConnect: boolean;
    function GetDBImplementationNo: LongInt;
    function GetDBImplementationClass: LongInt;
    function GetNoReserve: LongInt;
    function GetODSMinorVersion: LongInt;
    function GetODSMajorVersion: LongInt;
    function GetPageSize: LongInt;
    function GetVersion: string;
    function GetCurrentMemory: LongInt;
    function GetForcedWrites: LongInt;
    function GetMaxMemory: LongInt;
    function GetNumBuffers: LongInt;
    function GetSweepInterval: LongInt;
    procedure GetUserNames(AList: TStringList);

    function GetFetches: LongInt;
    function GetMarks: LongInt;
    function GetReads: LongInt;
    function GetWrites: LongInt;
    procedure GetBackoutCount(AList: TStringList);
    procedure GetDeleteCount(AList: TStringList);
    procedure GetExpungeCount(AList: TStringList);
    procedure GetInsertCount(AList: TStringList);
    procedure GetPurgeCount(AList: TStringList);
    procedure GetReadIdxCount(AList: TStringList);
    procedure GetReadSeqCount(AList: TStringList);
    procedure GetUpdateCount(AList: TStringList);
    function GetAllModifications:integer;

    function GetLogFile: LongInt;
    function GetCurLogFileName: string;
    function GetCurLogPartitionOffset: LongInt;
    function GetNumWALBuffers: LongInt;
    function GetWALBufferSize: LongInt;
    function GetWALCheckpointLength: LongInt;
    function GetWALCurCheckpointInterval: LongInt;
    function GetWALPrvCheckpointFilename: string;
    function GetWALPrvCheckpointPartOffset: LongInt;
    function GetWALGroupCommitWaitUSecs: LongInt;
    function GetWALNumIO: LongInt;
    function GetWALAverageIOSize: LongInt;
    function GetWALNumCommits: LongInt;
    function GetWALAverageGroupCommitSize: LongInt;

    //Firebird Info
    procedure GetActiveTransactions(AList: TStringList);
    function GetOldestTransaction: LongInt;
    function GetOldestActive: LongInt;
    function GetOldestSnapshot: LongInt;
    function GetFBVersion: string;
    function GetAttachCharset: integer;

    function  GetDBSQLDialect:Word;
    function  GetReadOnly: LongInt;
  end;

  IFbProvider = interface
    ['{53BBAF81-BD3A-489E-9020-2F0DF4F62260}']
    function AttachDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams): IFbAttachment;
    function CreateDatabase(AStatus: IFbStatus; AFileName: string; AParams: IFbAttachmentParams): IFbAttachment;
    function GetAttachmentParams: IFbAttachmentParams;
    function GetTransactionParams: IFbTransactionParams;
    function GetStatus: IFbStatus;
    function GetLibraryFilePath: string;
    property LibraryFilePath: string read GetLibraryFilePath;
  end;

implementation

end.
