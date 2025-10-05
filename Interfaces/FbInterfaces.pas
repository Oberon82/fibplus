unit FbInterfaces;

interface
uses
  System.Classes;

type

  IFbAttachment = interface;

  IFbStatus = interface
    ['{F369D131-F250-4713-A909-D424FEA3A4FD}']
    function HasErrors: boolean;
  end;

  IFbAttachmentParams = interface
    ['{296FCF3E-DEAC-4802-8ED8-7CFDF9C79229}']
    procedure GenerateParams(AParams: TStrings; IsFireBird: Boolean);
  end;

  IFbTransactionParams = interface
    ['{80FC062A-7367-4182-A1AD-1410329449F7}']
    procedure GenerateParams(AParams: TStrings; IsFB21orMore:boolean);
    procedure GenerateDistributedParams(Attachment: IFbAttachment);
  end;

  IFbTransaction = interface
    ['{DCA84E5B-B5A8-4E95-A9C8-F7015AC7E4BE}']
    procedure Commit(AStatus: IFbStatus);
    procedure CommitRetaining(AStatus: IFbStatus);
    procedure Rollback(AStatus: IFbStatus);
    procedure RollbackRetaining(AStatus: IFbStatus);
  end;

  IFbStatement = interface
    ['{6A0DFBDB-F11F-43E2-83C3-A1E384CC4AC1}']

  end;

  IFbBlob = interface
    ['{CB58D328-FB7E-45EB-8D52-5C2B618C1422}']

  end;

  IFbArray = interface
    ['{864B82DB-86F6-458F-A012-C0AA9F81CDF4}']

  end;

  IFbResultSet = interface
    ['{FDD8A8E0-0156-4519-B45E-AFA4D55726FC}']

  end;

  IFbMessageMetadata = interface
    ['{151A88A8-1266-41A5-8ED5-4864D3B8070D}']

  end;

  IFbAttachment = interface
    ['{363A7B48-4FCA-4DC4-9B78-7AC6F43E7FFA}']
    procedure DropDatabase(AStatus: IFbStatus);
    procedure DetachDatabase(AStatus: IFbStatus);

    function StartTransaction(AStatus: IFbStatus; AParams: IFbTransactionParams): IFbTransaction;
    function StartDistributedTransaction(AStatus: IFbStatus; AParams: IFbTransactionParams): IFbTransaction;

    function GetAttachmentID(AStatus: IFbStatus): LongInt;
    function GetAllocation(AStatus: IFbStatus): LongInt;
    function GetBaseLevel(AStatus: IFbStatus): LongInt;
    function GetDBFileName(AStatus: IFbStatus): Ansistring;
    function GetDBSiteName(AStatus: IFbStatus): Ansistring;
    function GetIsRemoteConnect(AStatus: IFbStatus): boolean;
    function GetDBImplementationNo(AStatus: IFbStatus): LongInt;
    function GetDBImplementationClass(AStatus: IFbStatus): LongInt;
    function GetNoReserve(AStatus: IFbStatus): LongInt;
    function GetODSMinorVersion(AStatus: IFbStatus): LongInt;
    function GetODSMajorVersion(AStatus: IFbStatus): LongInt;
    function GetPageSize(AStatus: IFbStatus): LongInt;
    function GetVersion(AStatus: IFbStatus): string;
    function GetCurrentMemory(AStatus: IFbStatus): LongInt;
    function GetForcedWrites(AStatus: IFbStatus): LongInt;
    function GetMaxMemory(AStatus: IFbStatus): LongInt;
    function GetNumBuffers(AStatus: IFbStatus): LongInt;
    function GetSweepInterval(AStatus: IFbStatus): LongInt;
    procedure GetUserNames(AStatus: IFbStatus; AList: TStringList);

    function GetFetches(AStatus: IFbStatus): LongInt;
    function GetMarks(AStatus: IFbStatus): LongInt;
    function GetReads(AStatus: IFbStatus): LongInt;
    function GetWrites(AStatus: IFbStatus): LongInt;
    procedure GetBackoutCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetDeleteCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetExpungeCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetInsertCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetPurgeCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetReadIdxCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetReadSeqCount(AStatus: IFbStatus; AList: TStringList);
    procedure GetUpdateCount(AStatus: IFbStatus; AList: TStringList);
    function GetAllModifications(AStatus: IFbStatus):integer;

    function GetLogFile(AStatus: IFbStatus): LongInt;
    function GetCurLogFileName(AStatus: IFbStatus): string;
    function GetCurLogPartitionOffset(AStatus: IFbStatus): LongInt;
    function GetNumWALBuffers(AStatus: IFbStatus): LongInt;
    function GetWALBufferSize(AStatus: IFbStatus): LongInt;
    function GetWALCheckpointLength(AStatus: IFbStatus): LongInt;
    function GetWALCurCheckpointInterval(AStatus: IFbStatus): LongInt;
    function GetWALPrvCheckpointFilename(AStatus: IFbStatus): string;
    function GetWALPrvCheckpointPartOffset(AStatus: IFbStatus): LongInt;
    function GetWALGroupCommitWaitUSecs(AStatus: IFbStatus): LongInt;
    function GetWALNumIO(AStatus: IFbStatus): LongInt;
    function GetWALAverageIOSize(AStatus: IFbStatus): LongInt;
    function GetWALNumCommits(AStatus: IFbStatus): LongInt;
    function GetWALAverageGroupCommitSize(AStatus: IFbStatus): LongInt;

    //Firebird Info
    procedure GetActiveTransactions(AStatus: IFbStatus; AList: TStringList);
    function GetOldestTransaction(AStatus: IFbStatus): LongInt;
    function GetOldestActive(AStatus: IFbStatus): LongInt;
    function GetOldestSnapshot(AStatus: IFbStatus): LongInt;
    function GetFBVersion(AStatus: IFbStatus): string;
    function GetAttachCharset(AStatus: IFbStatus): integer;

    function  GetDBSQLDialect(AStatus: IFbStatus):Word;
    function  GetReadOnly(AStatus: IFbStatus): LongInt;
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
